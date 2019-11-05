
module Oslc
  module Qm
    # Specification:
    #   http://open-services.net/bin/view/Main/QmSpecificationV2#Resource_TestPlan
    module TestPlan
      require_relative 'test_plan/resource_shape'
      require_relative 'test_plan/cache'
      require_relative 'test_plan/resource'
      require_relative 'test_plan/query'
      require_relative 'test_plan/resources'
      require_relative 'test_plan/creation_factory'
    end
  end
end
