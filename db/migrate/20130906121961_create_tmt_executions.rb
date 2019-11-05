class CreateTmtExecutions < ActiveRecord::Migration
  def change
    create_table :tmt_executions do |t|
      t.references :version, index: true
      t.references :test_run, index: true
      t.string :execution_result
      t.text  :comments
      t.string :execution_result_path
      t.integer :progress

      t.timestamps
    end
  end
end
