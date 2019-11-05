class RemoveNameFromTmtTestRunCustomFieldValue < ActiveRecord::Migration
  def change
    remove_column :tmt_test_run_custom_field_values, :name, :string
  end
end
