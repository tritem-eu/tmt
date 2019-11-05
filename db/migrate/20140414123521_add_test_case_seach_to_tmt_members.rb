class AddTestCaseSeachToTmtMembers < ActiveRecord::Migration
  def change
    add_column :tmt_members, :test_case_search, :text
  end
end
