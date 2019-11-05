class CreateTmtTestCases < ActiveRecord::Migration
  def change
    create_table :tmt_test_cases do |t|
      t.string     :name
      t.text       :description
      t.boolean    :locked
      t.boolean    :is_deleted, default: false
      t.references :project, index: true
      t.references :creator, index: true
      t.references :type, index: true
      t.integer    :versions_count, default: 0

      t.timestamps
    end
  end
end
