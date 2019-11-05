class CreateTmtCfgs < ActiveRecord::Migration
  def change
    create_table :tmt_cfgs do |t|
      t.string  :instance_name
      t.integer :test_cases_per_page
      t.integer :max_name_length, default: 40
      t.float   :file_size, default: 2 #MB
      t.string  :hello_message
      t.string  :hello_subtitle

      t.timestamps
    end
  end
end
