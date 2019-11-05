class RenameMachineIdToUserIdInTmtAutomationAdapters < ActiveRecord::Migration
  def up
    rename_column :tmt_automation_adapters, :machine_id, :user_id
  end

  def down
    rename_column :tmt_automation_adapters, :user_id, :machine_id
  end
end
