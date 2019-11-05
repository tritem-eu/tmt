class RenameMessageToParamsInTmtUserActivities < ActiveRecord::Migration
  def up
    rename_column :tmt_user_activities, :message, :params

    ActiveRecord::Base.transaction do
      Tmt::UserActivity.all.each do |entry|
        if entry.param_name == "Version" and Tmt::TestCaseVersion.exists?(id: entry.after_value)
          entry.update(params: {
              parser: :uploaded_version,
              version_id: entry.after_value.to_i,
              file_name: Base64.encode64(entry.before_value)
            },
            after_value: nil,
            before_value: nil
          )
        else
          entry.update(params: {parser: :custom_field})
        end
      end
    end
  end

  def down
    rename_column :tmt_user_activities, :params, :comment
  end
end
