# A Test Execution Record Query

# http://publib.boulder.ibm.com/infocenter/tivihelp/v8r1/index.jsp?topic=%2Fcom.ibm.netcoolimpact.doc6.1.1%2Fsolution%2Foslc_query_oslc_select_c.html
module Oslc
  module Qm
    module TestExecutionRecord
      class Resources < Oslc::Core::Resources
        def after_initialize
          define_resource_type 'oslc_qm:TestExecutionRecordQuery'
          define_entry_type 'oslc_qm:testExecutionRecord'
          define_resource_class ::Oslc::Qm::TestExecutionRecord::Resource
          @all_entries = ::Oslc::Qm::TestExecutionRecord::Query.new(provider: @provider).where(@oslc_where)
          @cache = Oslc::Qm::TestExecutionRecord::Cache.new(@all_entries, {project: @provider})
        end

        def namespaces
          ::Oslc::Qm::TestExecutionRecord::Resource.namespaces.merge({
            rdfs: :rdfs
          })
        end

      end
    end
  end
end
