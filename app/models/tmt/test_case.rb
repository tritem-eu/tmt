class Tmt::TestCase < ActiveRecord::Base
  include Tmt::UserActivityLog
  include Tmt::CustomField

  before_update do
    create_user_activities_for do |array|
      array << ["Name", name_was, name] if name_changed?
      array << ["Description", description_was, description] if description_changed?
    end
  end

  before_destroy do
    errors.add(:base, "You cannot destroy it")
    false
  end

  scope :undeleted, -> { where(deleted_at: nil).order(created_at: :desc) }

  belongs_to :project, class_name: "::Tmt::Project"
  belongs_to :creator, class_name: "::User"
  belongs_to :type, class_name: "::Tmt::TestCaseType"
  belongs_to :steward, class_name: "::User"

  has_many :custom_field_values, class_name: "::Tmt::TestCaseCustomFieldValue"
  has_many :custom_fields, through: :custom_field_values
  has_many :test_cases_sets, class_name: "::Tmt::TestCasesSets", foreign_key: :test_case_id
  has_many :sets, through: :test_cases_sets

  has_many :external_relationships, class_name: "::Tmt::ExternalRelationship", as: :source

  has_many :user_activities, :as => :observable
  has_many :versions, class_name: "Tmt::TestCaseVersion"
  has_many :executions, class_name: "Tmt::Execution", through: :versions
  has_many :test_runs, class_name: "Tmt::TestRun", through: :executions

  accepts_nested_attributes_for :versions
  validates_by_name :name
  validates :project_id, { presence: true }
  validates :creator_id, { presence: true }
  validate :validate_type_id
  validate :custom_fields_limits

  validate do
    if self.custom_field_values.map { |entry| entry.errors.any? }.include?(true)
      errors.add(:base, "Custom Field Value class is incorrectly")
    end
  end

  # virtual attributes
  # when locked is setted on true then his id should be setting in steward_id attribute (do it in controller)
  attr_accessor :locked

  #searchable do
  #  text :name, :boost => 2
  #  text :description
  #  boolean :is_deleted
  #end

  def active_versions
    versions.where.not(revision: nil)
  end

  # Return creator name
  def creator_name
    creator.name
  end

  # Return hash of date and ammount of test cases per one day
  def self.for_graph(type, options={})
    to = Date.today
    from = to.prev_day(30)
    result = {}
    (0..30).map {|offset| result[from.next_day(offset).to_s] = 0 }
    records = options[:test_cases].where(::Tmt::TestCase.arel_table[:created_at].gt(from))
    records.group_by{ |record| record.updated_at.beginning_of_day}.each do |key, value|
      date = key.strftime('%Y-%m-%d')
      result[date] = value.count if result[date]
    end
    result
  end

  # Return name of project
  def project_name
    project.name
  end

  def set_deleted
    self.update(deleted_at: Time.now)
  end

  # set locked attribute on true when locer_id is present
  def set_locked
    self.locked = nil
    self.locked = true if self.steward_id
  end

  # Controller can set steward_id and locked attributes for update or create action
  def set_steward_id_if(params, user)
    self.steward_id = nil
    self.steward_id = user.id if params['test_case'] and params['test_case']['locked'] == '1'
    self.locked = true if self.steward_id
    set_locked
  end

  def type_file?
    type and type.has_file
  end

  def type_extension
    type.extension
  end

  def type_name
    type.name if type
  end

  private

  def validate_type_id
    if self.id.nil?
      if not Tmt::TestCaseType.ids.include?(type_id) or type_id.blank?
        errors.add(:type_id, "Type id '#{self.type_id}' doesn't exist!")
      end
    else
      if type_id_changed?
        errors.add(:type_id, "Type of test case can't be changed")
      end
    end
  end

  def custom_fields_limits
    custom_field_values.each do |val|
      if (!val.valid?)
        unless !errors.nil?
          errors = errors.merge(val.errors)
        else
          errors = val.errors
        end
      end
    end
  end

end
