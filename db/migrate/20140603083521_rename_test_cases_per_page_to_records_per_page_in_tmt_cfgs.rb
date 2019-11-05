class RenameTestCasesPerPageToRecordsPerPageInTmtCfgs < ActiveRecord::Migration
  def change
    rename_column :tmt_cfgs, :test_cases_per_page, :records_per_page
    change_column :tmt_cfgs, :records_per_page, :integer, :default => 10
  end
end
