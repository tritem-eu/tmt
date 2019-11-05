class RenameIsDeletedInTmtTestRunCustomFieldsToDeletedAt < ActiveRecord::Migration
  def up
    rename_column :tmt_test_run_custom_fields, :is_deleted, :deleted_at
    change_column :tmt_test_run_custom_fields, :deleted_at, :datetime, default: nil
    Tmt::TestRunCustomField.all.each do |custom_field|
      custom_field.update(deleted_at: Time.now)
      custom_field.update(deleted_at: nil)
    end
  end

  def down
    rename_column :tmt_test_run_custom_fields, :deleted_at, :is_deleted
    change_column :tmt_test_run_custom_fields, :is_deleted, :boolean, default: false
    Tmt::TestRunCustomField.all.each do |custom_field|
      custom_field.update(is_deleted: false)
    end

  end
end
