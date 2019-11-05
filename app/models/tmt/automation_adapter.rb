class Tmt::AutomationAdapter < ActiveRecord::Base
  belongs_to :project, class_name: 'Tmt::Project'
  belongs_to :user, class_name: '::User'
  has_one :machine, through: :user

  validates_by_name :name, uniqueness: true

  validates :project_id, { presence: true }
  validates :user_id, { presence: true }

  validates :polling_interval, numericality: {only_integer: true, greater_than_or_equal_to: 1, less_than_or_equal_to: 60*60*24}

  validate do
    unless Tmt.config.value(:oslc, :execution_adapter_type, :id) == self.adapter_type
      errors.add(:adapter_type, "does not exist")
    end
  end

  def self.adapter_types
    adapter_type = Tmt.config.value(:oslc, :execution_adapter_type, :id)
    if adapter_type
      [adapter_type]
    else
      []
    end
  end

  def test_runs
    if project
      project.test_runs.where(executor_id: self.user_id)
    end
  end

  def mac_address
    if machine
      machine.mac_address
    end
  end

  def ip_address
    if machine
      machine.ip_address
    end
  end

  def creator
    user
  end

  def hostname
    if machine
      machine.hostname
    end
  end

  def fully_qualified_domain_name
    if machine
      machine.fully_qualified_domain_name
    end
  end

  def work_available
    test_run_ids = self.project.test_runs.conditions_for_automation_requests.where(executor_id: self.user_id).pluck(:id)
    self.project.executions.where(status: ::Tmt::Execution::STATUS_NONE, test_run_id: test_run_ids).any?
  end

end
