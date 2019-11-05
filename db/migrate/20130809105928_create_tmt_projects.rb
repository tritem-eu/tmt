class CreateTmtProjects < ActiveRecord::Migration
  def change
    create_table :tmt_projects do |t|
      t.references :creator, index: true
      t.string :name, index: true, unique: true
      t.text :description
      t.references :default_type, index: true

      t.timestamps
    end
  end
end
