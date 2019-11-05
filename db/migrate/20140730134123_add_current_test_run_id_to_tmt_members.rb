class AddCurrentTestRunIdToTmtMembers < ActiveRecord::Migration
  def change
    add_reference :tmt_members, :current_test_run, index: true
  end
end
