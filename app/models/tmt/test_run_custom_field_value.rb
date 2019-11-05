module Tmt
  class TestRunCustomFieldValue < ActiveRecord::Base
    include Tmt::CustomFieldValueConcern
    include Tmt::UserActivityLog

    before_save do
      user_activities = self.test_run.user_activities
      create_user_activities_for({
        user_activities: user_activities,
        project_id: test_run.project.id
      }) do |array|
        value_was = self.custom_field.value_for(test_run_id)
        array << [custom_field_name.to_s.humanize, value_was, value]
      end
    end

  end
end
