# Automation Request Query

module Oslc
  module Qm
    module TestResult
      class Resources < Oslc::Core::Resources

        def after_initialize
          define_resource_type 'oslc_qm:TestResultQuery'
          define_entry_type 'oslc_qm:testResult'
          define_resource_class ::Oslc::Qm::TestResult::Resource
          @all_entries = ::Oslc::Qm::TestResult::Query.new(provider: @provider).where(@oslc_where)
          @cache = Oslc::Qm::TestResult::Cache.new(@all_entries)
          @cache.project = @provider
        end

        def namespaces
          ::Oslc::Qm::TestResult::Resource.namespaces.merge({
            rdfs: :rdfs
          })
        end

      end
    end
  end
end
