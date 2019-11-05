class RenameCommentsToCommentInTmtExecutions < ActiveRecord::Migration
  def up
    rename_column :tmt_executions, :comments, :comment
  end

  def down
    rename_column :tmt_executions, :rcomment, :comments
  end
end
