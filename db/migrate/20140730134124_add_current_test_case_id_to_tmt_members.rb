class AddCurrentTestCaseIdToTmtMembers < ActiveRecord::Migration
  def change
    add_reference :tmt_members, :current_test_case, index: true
  end
end
