class AddDeletedAtToTmtTestCases < ActiveRecord::Migration
  def change
    add_column :tmt_test_cases, :deleted_at, :datetime, default: nil

    Tmt::TestCase.all.each do |test_case|
      test_case.update(deleted_at: Time.now) if test_case.is_deleted
    end

    remove_column :tmt_test_cases, :is_deleted, :boolean
  end
end
