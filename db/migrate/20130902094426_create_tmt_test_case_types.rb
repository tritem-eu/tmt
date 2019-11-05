class CreateTmtTestCaseTypes < ActiveRecord::Migration
  def change
    create_table :tmt_test_case_types do |t|
      t.string :name
      t.boolean :has_file
      t.string :extension
      t.string :converter

      t.timestamps
    end
  end
end
