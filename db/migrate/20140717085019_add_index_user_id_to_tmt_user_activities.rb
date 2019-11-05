class AddIndexUserIdToTmtUserActivities < ActiveRecord::Migration
  def change
    add_index :tmt_user_activities, :user_id
  end
end
