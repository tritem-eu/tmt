class CreateTmtTestCaseVersions < ActiveRecord::Migration
  def change
    create_table :tmt_test_case_versions do |t|
      t.references :test_case, index: true
      t.string :file_name
      t.string :revision
      t.integer :file_size
      t.string :comment
      t.references :author, index: true

      t.timestamps
    end
  end
end
