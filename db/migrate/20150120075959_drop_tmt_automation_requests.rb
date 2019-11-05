class DropTmtAutomationRequests < ActiveRecord::Migration
  def change
    drop_table :tmt_automation_requests
  end
end
