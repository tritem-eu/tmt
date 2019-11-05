# Automation Request Query

module Oslc
  module Automation
    module Request
      class Resources < Oslc::Core::Resources

        def after_initialize
          define_resource_type 'oslc_auto:AutomationRequestQuery'
          define_entry_type 'oslc_auto:automationRequest'
          define_resource_class ::Oslc::Automation::Request::Resource
          @all_entries = ::Oslc::Automation::Request::Query.new(provider: @provider).where(@oslc_where)
          @cache = Oslc::Automation::Request::Cache.new(@all_entries)
        end

        def namespaces
          ::Oslc::Automation::Request::Resource.namespaces.merge({
            rdfs: :rdfs
          })
        end

      end
    end
  end
end
