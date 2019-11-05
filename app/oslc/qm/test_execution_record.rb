
# Specification:
#   http://open-services.net/bin/view/Main/QmSpecificationV2#Resource_TestExecutionRecord
# Example:
#   http://open-services.net/bin/view/Main/QmSpecificationV2Samples#TestExecutionRecord_RDF_XML
module Oslc
  module Qm
    module TestExecutionRecord
      require_relative 'test_execution_record/resource_shape'
      require_relative 'test_execution_record/resource'
      require_relative 'test_execution_record/query'
      require_relative 'test_execution_record/cache'
      require_relative 'test_execution_record/resources'
    end
  end
end
