module Tmt
  class TestRun < ActiveRecord::Base
    include Tmt::UserActivityLog
    include Tmt::CustomField

    STATUS_NEW = 1
    STATUS_PLANNED = 2
    STATUS_EXECUTING = 3
    STATUS_DONE = 4

    after_initialize do
      self.status ||= 1
      self.due_date = Time.now if self.id.nil?
    end

    before_update do
      create_user_activities_for do |array|
        array << ["Name", name_was, name] if name_changed?
        array << ["Status", statuses[status_was], statuses[status]] if status_changed?
        array << ["Description", description_was, description] if description_changed?
        array << ["Due date", due_date_was.to_s.first(19), due_date.to_s.first(19)] if due_date_changed?
        array << ["Executor", nil, (executor ? executor.name : nil)] if executor_id_changed?
      end
    end

    after_update only: :show do
      self.touch unless self.new_record?
    end

    after_save :update_status

    before_save :set_due_date_with_current_time

    scope :undeleted, -> { where(deleted_at: nil).order(due_date: :desc) }
    scope :with_status_done, -> { where(status: ::Tmt::TestRun::STATUS_DONE) }
    scope :conditions_for_automation_requests, -> {
      test_run = Tmt::TestRun.arel_table
      where.not(status: ::Tmt::TestRun::STATUS_NEW).where(test_run[:due_date].lteq(Time.now))
    }

    belongs_to :campaign, class_name: "Tmt::Campaign"
    belongs_to :creator, class_name: "User"
    belongs_to :executor, class_name: "User"

    has_many :executions, class_name: "Tmt::Execution", foreign_key: "test_run_id"
    has_many :versions, through: :executions, source: :version, class_name: "Tmt::TestCaseVersion"
    has_many :test_cases, through: :versions, source: :test_case, class_name: "Tmt::TestCase"
    has_many :custom_field_values, class_name: "Tmt::TestRunCustomFieldValue", foreign_key: :test_run_id
    has_many :custom_fields, through: :custom_field_values

    has_many :user_activities, :as => :observable

    validate do
      max_name_length = ::Tmt::Cfg.max_name_length
      unless self.name.to_s.length.between?(1, max_name_length)
        errors.add(:name, I18n.t(:does_not_have_length_between_and, scope: [:models, :test_run], from: 1, to: max_name_length))
      end
    end

    validate do
      if self.custom_field_values.map { |entry| entry.errors.any? }.include?(true)
        errors.add(:base, "Custom Field Value class is incorrectly")
      end
    end

    validates :creator_id, {presence: true}
    validates :campaign_id, {presence: true}
    validate :validate_executor_belongs_to_project
    validate :validate_status

    delegate :project, to: :campaign

    scope :planned, -> { where(status: 2) }

    def deleted_test_cases
      self.test_cases.where.not(deleted_at: nil)
    end

    def set_record_for_cloning(options={})
      result = self.dup
      result.status = 1
      result.creator = options[:creator] if options[:creator]
      project = result.project
      open_campaign = project.open_campaign
      result.campaign = open_campaign
      result
    end

    def clone_record(options={})
      result = set_record_for_cloning(options)
      return unless result.campaign
      ActiveRecord::Base.transaction do
        result.save(validate: false)
        self.executions.each do |execution|
          Tmt::Execution.create(test_run_id: result.id, version_id: execution.version_id)
        end
        self.custom_field_values.each do |value|
          custom_field_value = value.dup
          custom_field_value.test_run_id = result.id
          custom_field_value.save
        end
      end
      return if result.id.nil?
      result
    end

    def set_deleted
      self.update(deleted_at: Time.now)
    end

    # input: array of test_case_versions
    def push_versions(version_ids)
      return false unless self.has_status?(:new)
      if Array === version_ids
        version_ids = project.test_case_versions.pluck(:id) & version_ids.map(&:to_i)
        version_ids.each do |version_id|
          self.executions.create(version_id: version_id)
        end
      end
      true
    end

    # Return month array with records
    def self.calendar_with_records(test_runs, year, month)
      result = ::Tmt::Lib::Calendar.generate_with(year, month)
      test_runs.each do |test_run|
        column = test_run.due_date.wday
        day = test_run.due_date.day
        row = (Date.new(year, month, 1).wday + day - 1) / 7
        if result[row] and result[row][column]
          result[row][column][:test_runs] ||= []
          result[row][column][:test_runs] << test_run
        end
      end
      result
    end

    # return true when user can change status from new into planned
    def can_set_status_planned?
      self.status == STATUS_NEW and
      not self.executor.nil? and
      versions.any? and
      not self.due_date.blank? and
      self.deleted_test_cases.blank?
    end

    def executor_machine?
      executor and executor.machine?
    end

    def set_status_planned
      if can_set_status_planned?
        self.update(status: 2)
      else
        false
      end
    end

    def set_status_executing
      if status == 2
        self.update(status: 3)
      else
        false
      end
    end

    def set_status_new
      if status == 2
        self.update(status: 1)
      else
        false
      end
    end

    def has_status?(*array)
      raise(ArgumentError, 'name or or_next_name have got incorrect status') unless (statuses.values & array).sort == array.sort
      array.include?(statuses[self.status])
    end

    # return hash of statuses number
    # executions_statuses_counter #=> {none: 1, executing: 1, passed: 2, error: 0, failed: 1}
    def executions_statuses_counter
      result = {}
      executions.map(&:status).each do |status|
        result[status.to_sym] ||= 0
        result[status.to_sym] += 1
      end
      result
    end

    def fails_num
      executions.failed.count
    end

    def passes_num
      executions.passed.size
    end

    def exec_num
      executions.executing.count
    end

    def error_num
      executions.error.count
    end

    def status_name
      statuses[self.status]
    end

    def update_status
      if self.status == 3 #executing
        if executions.size == (error_num + passes_num + fails_num)
          self.update(status: 4)
        end
      elsif (self.status == 2) #planned
        if (error_num + passes_num + fails_num + exec_num) > 0
          set_status_executing
        end
      end
    end

    def self.for_graph(type, options={})
      to = Date.today
      from = to.prev_day(30)
      result = {}
      (0..30).map {|offset| result[from.next_day(offset).to_s] = 0 }
      if options[:test_runs]
        a_test_run = ::Tmt::TestRun.arel_table
        records = options[:test_runs].where(a_test_run[:status].gt(3).and(a_test_run[:updated_at].gt(from)))
        records.group_by{ |record| record.updated_at.beginning_of_day}.each do |key, value|
          date = key.strftime('%Y-%m-%d')
          result[date] = value.count if result[date]
        end
      else
        where(id: nil)
      end
      result
    end

    def self.statuses
      {
        STATUS_NEW => :new,
        STATUS_PLANNED => :planned,
        STATUS_EXECUTING => :executing,
        STATUS_DONE => :done
      }
    end

    def statuses
      self.class.statuses
    end

    def terminate(user)
      return false unless self.has_status?(:planned, :executing)
      ActiveRecord::Base.transaction do
        self.set_status_executing
        self.executions.each do |execution|
          execution.update(status: 'error', comment: "The User with #{user.email} email terminated this execution.")
        end
      end
      self.reload.has_status?(:done)
    end

    private

    def validate_executor_belongs_to_project
      unless executor_id.nil?
        unless project.users.include?(executor)
          errors.add(:executor, "Selected user doesn't belong to the current project.")
        end
      end
    end

    def validate_status
      unless statuses.keys.include?(self.status)
        errors.add(:status, "Status '#{self.status}' is incorrect")
      end
    end

    def set_due_date_with_current_time
      if self.status == 1 and self.due_date and self.due_date < Time.now
        self.due_date = Time.now
      end
    end

  end
end
