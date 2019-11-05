# Automation Plan Query

module Oslc
  module Automation
    module Plan
      class Resources < ::Oslc::Core::Resources

        def after_initialize
          define_entry_type "oslc_auto:automationPlan"
          define_resource_type "oslc_auto:AutomationPlanQuery"
          define_resource_class ::Oslc::Automation::Plan::Resource
          @all_entries = ::Oslc::Automation::Plan::Query.new(provider: @provider).where(@oslc_where)
          @cache = Oslc::Automation::Plan::Cache.new(@all_entries)
        end

        def namespaces
          ::Oslc::Automation::Plan::Resource.namespaces.merge({
            oslc_auto: :oslc_auto
          })
        end

      end
    end
  end
end
