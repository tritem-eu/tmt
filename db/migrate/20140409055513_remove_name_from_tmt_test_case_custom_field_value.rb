class RemoveNameFromTmtTestCaseCustomFieldValue < ActiveRecord::Migration
  def change
    remove_column :tmt_test_case_custom_field_values, :name, :string
  end
end
