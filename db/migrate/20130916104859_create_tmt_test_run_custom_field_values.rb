class CreateTmtTestRunCustomFieldValues < ActiveRecord::Migration
  def change
    create_table  :tmt_test_run_custom_field_values do |t|
      t.string      :name
      t.references  :test_run, index: true
      t.references  :custom_field, index: true
      t.integer     :int_value
      t.text        :text_value
      t.string      :string_value
      t.integer     :enum_value
      t.datetime    :date_value
      t.boolean     :bool_value

      t.timestamps
    end
  end
end
