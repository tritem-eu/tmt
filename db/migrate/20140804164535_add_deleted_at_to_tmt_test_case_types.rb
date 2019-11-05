class AddDeletedAtToTmtTestCaseTypes < ActiveRecord::Migration
  def change
    add_column :tmt_test_case_types, :deleted_at, :datetime, default: nil

    Tmt::TestCaseType.all.each do |type|
      type.update(deleted_at: Time.now) if type.is_deleted
    end

    remove_column :tmt_test_case_types, :is_deleted, :boolean
  end
end
