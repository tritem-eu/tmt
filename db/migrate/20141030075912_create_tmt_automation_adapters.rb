class CreateTmtAutomationAdapters < ActiveRecord::Migration
  def change
    create_table :tmt_automation_adapters do |t|
      t.references :project, index: true
      t.string :title
      t.string :adapter_type
      t.integer :polling_interval
      t.text :description

      t.timestamps
    end
  end
end
