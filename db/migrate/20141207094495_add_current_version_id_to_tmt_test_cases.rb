class AddCurrentVersionIdToTmtTestCases < ActiveRecord::Migration
  def change
    add_column :tmt_test_cases, :current_version_id, :integer, default: nil, references: 'current_version'
  end
end
