module Oslc
  module Qm
    # Specification:
    #   http://open-services.net/bin/view/Main/QmSpecificationV2#Resource_TestCase
    # Example:
    #   http://open-services.net/bin/view/Main/QmSpecificationV2Samples#TestCase_RDF_XML
    module TestCase
      require_relative 'test_case/creation_factory'
      require_relative 'test_case/modify'
      require_relative 'test_case/cache'
      require_relative 'test_case/resource'
      require_relative 'test_case/query'
      require_relative 'test_case/resources'
      require_relative 'test_case/resource_shape'
    end
  end
end
