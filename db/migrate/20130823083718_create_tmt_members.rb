class CreateTmtMembers < ActiveRecord::Migration
  def change
    create_table :tmt_members do |t|
      t.references :project, index: true
      t.references :user, index: true
      t.text :set_ids
      t.text :nav_tab
      t.boolean :is_active

      t.timestamps
    end
  end
end
