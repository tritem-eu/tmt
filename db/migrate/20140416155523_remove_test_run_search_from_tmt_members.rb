class RemoveTestRunSearchFromTmtMembers < ActiveRecord::Migration
  def change
    remove_column :tmt_members, :test_run_search, :text
  end
end
