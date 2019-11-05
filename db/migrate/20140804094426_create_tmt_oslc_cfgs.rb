class CreateTmtOslcCfgs < ActiveRecord::Migration
  def change
    create_table :tmt_oslc_cfgs do |t|
      t.references :test_case_type, index: true

      t.timestamps
    end
  end
end
