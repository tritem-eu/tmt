# Automation Adapter Query

module Oslc
  module Qm
    module TestScript
      class Resources < Oslc::Core::Resources
        def after_initialize
          define_resource_type 'oslc_qm:TestScriptQuery'
          define_entry_type "oslc_qm:testScript"
          define_resource_class ::Oslc::Qm::TestScript::Resource
          @all_entries = ::Oslc::Qm::TestScript::Query.new(provider: @provider).where(@oslc_where)
        end

        def namespaces
          ::Oslc::Qm::TestScript::Resource.namespaces.merge({
            oslc_auto: :oslc_auto
          })
        end

      end
    end
  end
end
