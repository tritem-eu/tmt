class AddTakenToTmtExecutions < ActiveRecord::Migration
  def change
    add_column :tmt_executions, :taken, :boolean, default: false
  end
end
