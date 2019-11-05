class CreateTmtTestRuns < ActiveRecord::Migration
  def change
    create_table :tmt_test_runs do |t|
      t.references :campaign, index: true
      t.string     :name
      t.text       :description
      t.datetime   :due_date
      t.boolean    :is_deleted, default: false
      t.references :creator, index: true
      t.references :executor, index: true
      t.integer    :status

      t.timestamps
    end
  end
end
