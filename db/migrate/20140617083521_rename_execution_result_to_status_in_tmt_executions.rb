class RenameExecutionResultToStatusInTmtExecutions < ActiveRecord::Migration
  def up
    rename_column :tmt_executions, :execution_result, :status
  end

  def down
    rename_column :tmt_executions, :status, :execution_result
  end
end
