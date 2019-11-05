class CreateTmtUserActivities < ActiveRecord::Migration
  def change
    create_table :tmt_user_activities do |t|
      t.integer :user_id
      t.integer :observable_id
      t.string :observable_type
      t.string :message
      t.string :param_name
      t.string :before_value
      t.string :after_value
      t.references :project

      t.timestamps
    end
  end
end
