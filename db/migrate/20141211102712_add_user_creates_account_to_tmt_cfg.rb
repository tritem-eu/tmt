class AddUserCreatesAccountToTmtCfg < ActiveRecord::Migration
  def change
    add_column :tmt_cfgs, :user_creates_account, :boolean, default: false
  end
end
