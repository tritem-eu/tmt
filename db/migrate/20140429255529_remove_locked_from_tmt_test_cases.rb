class RemoveLockedFromTmtTestCases < ActiveRecord::Migration
  def change
    remove_column :tmt_test_cases, :locked, :boolean
  end
end
