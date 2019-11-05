class RemoveTestCaseSearchFromTmtMembers < ActiveRecord::Migration
  def change
    remove_column :tmt_members, :test_case_search, :text
  end
end
