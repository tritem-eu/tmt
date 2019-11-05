class AddTimezoneToTmtCfgs < ActiveRecord::Migration
  def change
    add_column :tmt_cfgs, :time_zone, :string
  end
end
