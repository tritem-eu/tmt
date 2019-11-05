class RenameLockerIdToStewardIdInTmtTestCases < ActiveRecord::Migration
  def up
    rename_column :tmt_test_cases, :locker_id, :steward_id
  end

  def down
    rename_column :tmt_test_cases, :steward_id, :locker_id
  end
end
