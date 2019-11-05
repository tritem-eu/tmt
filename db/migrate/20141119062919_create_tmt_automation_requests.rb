class CreateTmtAutomationRequests < ActiveRecord::Migration
  def change
    create_table :tmt_automation_requests do |t|
      t.references :project, index: true
      t.string :output_parameter
      t.string :input_parameter
      t.references :executes_test_script, index: true
      t.references :contributor, index: true
      t.references :executes_on_adapter, index: true
      t.references :creator, index: true
      t.string :request_type
      t.integer :progress
      t.references :executes_automation_plan, index: true
      t.boolean :taken
      t.string :state
      t.string :title

      t.timestamps
    end
  end
end
