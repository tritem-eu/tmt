class RemoveTakenFromTmtExecutions < ActiveRecord::Migration

  def change
    remove_column :tmt_executions, :taken
  end
end
