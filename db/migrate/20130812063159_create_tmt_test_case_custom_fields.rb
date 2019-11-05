class CreateTmtTestCaseCustomFields < ActiveRecord::Migration
  def change
    create_table :tmt_test_case_custom_fields do |t|
      t.string      :name
      t.text        :description
      t.string      :type_name
      t.boolean     :is_deleted, default: false
      t.integer     :upper_limit
      t.references  :project, index: true
      t.integer     :lower_limit
      t.text        :default_value

      t.timestamps
    end
  end
end
