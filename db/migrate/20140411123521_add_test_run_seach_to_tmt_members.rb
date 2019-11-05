class AddTestRunSeachToTmtMembers < ActiveRecord::Migration
  def change
    add_column :tmt_members, :test_run_search, :text
  end
end
