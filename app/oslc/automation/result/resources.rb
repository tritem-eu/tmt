# Automation Request Query

module Oslc
  module Automation
    module Result
      class Resources < Oslc::Core::Resources

        def after_initialize
          define_resource_type 'oslc_auto:AutomationResultQuery'
          define_entry_type 'oslc_auto:automationResult'
          define_resource_class ::Oslc::Automation::Result::Resource
          @all_entries = ::Oslc::Automation::Result::Query.new(provider: @provider).where(@oslc_where)
        end

        def namespaces
          ::Oslc::Automation::Result::Resource.namespaces.merge({
            rdfs: :rdfs
          })
        end

      end
    end
  end
end
