class RenameExecutionResultPathToResultPathInTmtExecutions < ActiveRecord::Migration
  def up
    rename_column :tmt_executions, :execution_result_path, :result_path
  end

  def down
    rename_column :tmt_executions, :result_path, :execution_result_path
  end
end
