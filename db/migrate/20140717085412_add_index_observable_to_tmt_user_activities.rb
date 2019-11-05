class AddIndexObservableToTmtUserActivities < ActiveRecord::Migration
  def change
    add_index :tmt_user_activities, [:observable_id, :observable_type]
  end
end
