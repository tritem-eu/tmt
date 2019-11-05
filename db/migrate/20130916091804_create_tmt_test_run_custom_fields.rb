class CreateTmtTestRunCustomFields < ActiveRecord::Migration
  def change
    create_table :tmt_test_run_custom_fields do |t|
      t.string      :name
      t.text        :description
      t.string      :type_name
      t.boolean     :is_deleted, default: false
      t.references  :project, index: true
      t.integer     :upper_limit
      t.integer     :lower_limit
      t.string      :default_value

      t.timestamps
    end
  end
end
