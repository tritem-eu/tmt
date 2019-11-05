class AddDeletedAtToTmtTestRuns < ActiveRecord::Migration
  def change
    add_column :tmt_test_runs, :deleted_at, :datetime, default: nil

    Tmt::TestRun.all.each do |test_run|
      test_run.update(deleted_at: Time.now) if test_run.is_deleted
    end

    remove_column :tmt_test_runs, :is_deleted, :boolean
  end
end
