class CreateTmtTestCasesSets < ActiveRecord::Migration
  def change
    create_table :tmt_test_cases_sets do |t|
      t.references :test_case, index: true
      t.references :set,       index: true

      t.timestamps
    end
  end
end
