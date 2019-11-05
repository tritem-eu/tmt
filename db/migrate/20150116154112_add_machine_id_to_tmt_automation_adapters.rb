class AddMachineIdToTmtAutomationAdapters < ActiveRecord::Migration
  def change
    add_reference :tmt_automation_adapters, :machine, index: true
  end
end
