class CreateTmtEnumerations < ActiveRecord::Migration
  def change
    create_table :tmt_enumerations do |t|
      t.references :test_case_custom_field, index: true
      t.references :test_run_custom_field, index: true
      t.string :name
      t.integer :default

      t.timestamps
    end
  end
end
