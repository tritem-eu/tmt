class RenameTitleInTmtAutomationAdaptersToName < ActiveRecord::Migration
  def up
    rename_column :tmt_automation_adapters, :title, :name
  end

  def down
    rename_column :tmt_automation_adapters, :name, :title
  end
end
