class CreateTmtCampaigns < ActiveRecord::Migration
  def change
    create_table :tmt_campaigns do |t|
      t.datetime :deadline_at
      t.boolean :is_open
      t.string :name
      t.references :project, index: true

      t.timestamps
    end
  end
end
