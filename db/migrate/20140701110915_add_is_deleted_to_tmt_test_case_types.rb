class AddIsDeletedToTmtTestCaseTypes < ActiveRecord::Migration
  def change
    add_column :tmt_test_case_types, :is_deleted, :boolean, default: false
  end
end
