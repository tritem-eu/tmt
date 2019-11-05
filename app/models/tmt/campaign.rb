module Tmt
  class Campaign < ActiveRecord::Base
    belongs_to :project, class_name: "Tmt::Project"
    has_many :test_runs, class_name: "Tmt::TestRun"

    before_create :set_is_open

    validates :project, {presence: true}
    validates_by_name :name, uniqueness: {scope: :project_id, message: "The name should be unique"}
    validate :exist_open_campaign
    validate :update_only_open_campaign
    validate do
      max_name_length = ::Tmt::Cfg.max_name_length
      unless self.name.to_s.length.between?(1, max_name_length)
        errors.add(:name, I18n.t(:does_not_have_length_between_and, scope: [:models, :campaign], from: 1, to: max_name_length))
      end
    end

    validate do
      message = @deadline_at_error
      if not message.nil?
        errors.add(:deadline_at, message)
      end
    end

    def deadline_at=(date)
      begin
        parsed = Time.zone.parse(date)
        self[:deadline_at] = parsed
      rescue
        @deadline_at_error = "invalid deadline"
        self[:deadline_at] = date
      end
    end

    def self.project_campaigns(project_id)
      Tmt::Campaign.where(project_id: project_id)
    end

    # Close the campaign
    def close
      self.is_open = false,
      self.deadline_at = Time.now
      self.save(validate: false)
    end

    def new_test_runs
      self.undeleted_test_runs.where(status: 1)
    end

    def undeleted_test_runs
      test_runs.undeleted
    end

    def done_test_runs
      undeleted_test_runs.where(status: 4)
    end

    private

    def exist_open_campaign
      return true unless self.id.nil?
      return true if self.project.nil?
      opens = self.class.project_campaigns(project.id).map(&:is_open)
      if opens.include?(true)
        errors.add(:base, "Project has an open campaign.")
      end
    end

    def set_is_open
      self.is_open = true
    end

    def update_only_open_campaign
      if not self.id.nil? and not self.is_open
        errors.add(:base, "You cannot update closed campaign.")
      end
    end

  end
end
