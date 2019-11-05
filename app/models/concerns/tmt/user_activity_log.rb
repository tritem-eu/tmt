module Tmt
  module UserActivityLog
    extend ActiveSupport::Concern

    included do

      # All changes of user should be defined in this method
      # Example:
      # create_user_activities_for do |array|
      #  array << ["Name", name_was, name] if name_changed?
      #  array << ["Description", description_was, description] if description_changed?
      # end
      def create_user_activities_for(options={}, &block)
        to_create = []
        if block_given?
          block.call(to_create)
          to_create.each do |param_name, before_value, after_value|
            next if before_value.blank? and after_value.blank?
            next if before_value == after_value
            (options[:user_activities] || user_activities).create(
              user_id: ::User.updater_id,
              params: {parser: :custom_field},
              param_name: (options[:param_name] || param_name),
              before_value: before_value,
              after_value: after_value,
              project_id: (options[:project_id] || project.id)
            )
          end
        end
      end

    end

  end
end
