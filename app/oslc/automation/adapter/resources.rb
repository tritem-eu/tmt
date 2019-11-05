# Automation Adapter Query
module Oslc
  module Automation
    module Adapter
      class Resources < Oslc::Core::Resources

        def after_initialize
          define_resource_type 'rqm_auto:AutomationAdapterQuery'
          define_entry_type 'oslc_auto:automationAdapter'
          define_resource_class ::Oslc::Automation::Adapter::Resource
          @all_entries = ::Oslc::Automation::Adapter::Query.new(provider: @provider).where(@oslc_where)
          @cache = ::Oslc::Automation::Adapter::Cache.new(@all_entries)
        end

        def namespaces
          ::Oslc::Automation::Adapter::Resource.namespaces.merge({
            oslc_auto: :oslc_auto
          })
        end

      end
    end
  end
end
