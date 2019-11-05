class CreateTmtSets < ActiveRecord::Migration
  def change
    create_table :tmt_sets do |t|
      t.string :name
      t.references :parent, index: true
      t.references :project, index: true
      t.integer :children_count, default: 0

      t.timestamps
    end
  end
end
