
# Specification:
#   http://open-services.net/bin/view/Main/QmSpecificationV2#Resource_TestResult
# Example:
#   http://open-services.net/bin/view/Main/QmSpecificationV2Samples#TestResult_RDF_XML
module Oslc
  module Qm
    module TestResult
      require_relative 'test_result/resource_shape'
      require_relative 'test_result/cache'
      require_relative 'test_result/resource'
      require_relative 'test_result/query'
      require_relative 'test_result/resources'
    end
  end
end
