class CreateTmtExternalRelationships < ActiveRecord::Migration
  def change
    create_table :tmt_external_relationships do |t|
      t.text :value
      t.string :url
      t.integer :rq_id
      t.references :source, polymorphic: true, index: true

      t.timestamps
    end
  end
end
