# A Test Plan Query

# http://publib.boulder.ibm.com/infocenter/tivihelp/v8r1/index.jsp?topic=%2Fcom.ibm.netcoolimpact.doc6.1.1%2Fsolution%2Foslc_query_oslc_select_c.html
module Oslc
  module Qm
    module TestCase
      class Resources < Oslc::Core::Resources

        def after_initialize
          define_resource_type 'oslc_qm:TestCaseQuery'
          define_entry_type 'oslc_qm:testCase'
          define_resource_class ::Oslc::Qm::TestCase::Resource
          @all_entries = ::Oslc::Qm::TestCase::Query.new(provider: @provider).where(@oslc_where)
          @cache = ::Oslc::Qm::TestCase::Cache.new(@all_entries)
          @cache.project = @provider
        end

        def namespaces
          ::Oslc::Qm::TestCase::Resource.namespaces
        end

      end
    end
  end
end
