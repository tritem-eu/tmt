class AddLockerIdToTmtTestCases < ActiveRecord::Migration
  def change
    add_reference :tmt_test_cases, :locker, index: true
  end
end
