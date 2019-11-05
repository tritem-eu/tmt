module Tmt
  class Project < ActiveRecord::Base
    has_many :campaigns, class_name: "Tmt::Campaign"
    belongs_to :creator, class_name: "User", foreign_key: :creator_id

    has_many :automation_adapters, class_name: "Tmt::AutomationAdapter"

    has_many :members, -> { where(is_active: true) }, class_name: "Tmt::Member"
    has_many :users, through: :members
    has_many :test_cases, class_name: "Tmt::TestCase"
    has_many :test_runs, through: :campaigns
    has_many :executions, through: :test_runs
    has_many :user_activities, class_name: "Tmt::UserActivity"
    has_many :test_case_versions, through: :test_cases, source: :versions
    has_many :sets, class_name: "Tmt::Set"
    has_one  :default_type, class_name: "Tmt::TestCaseType"
    validates :name, {uniqueness: true}

    validates :creator, { presence: true }

    validates_by_name :name, uniqueness: true

    # Return list of project where user_id has access
    def self.user_projects(user)
      user_id = ( user ? user.id : nil )
      member = Tmt::Member.arel_table
      Tmt::Project.joins(:members).where(member[:user_id].eq(user_id).and(member[:is_active].eq(true)))
    end

    def add_member(user)
      entry = ::Tmt::Member.where(project: self, user: user).first_or_initialize
      entry.is_active = true
      entry.save!
    end

    # Return name od creator
    def creator_name
      creator.name if creator
    end

    # return open campaign or nil when campaigns are closed
    def open_campaign
      @open_campaign ||= Tmt::Campaign.where(project_id: id, is_open: true).first
    end

    def open_campaign_id
      open_campaign.id
    rescue
      nil
    end

    # return true when project has got open campaign
    def has_open_campaigns?
      return true if open_campaign
      false
    end

    def base_uri
      project_path(self)
    end

    def undeleted_test_cases
      self.test_cases.undeleted
    end

    def undeleted_test_runs
      self.test_runs.undeleted
    end

    def done_test_runs
      self.undeleted_test_runs.with_status_done
    end
  end
end
