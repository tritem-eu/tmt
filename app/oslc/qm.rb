require_relative 'qm/service_provider_catalog'
require_relative 'qm/service_provider'

require_relative 'qm/test_case'
require_relative 'qm/test_execution_record'
require_relative 'qm/test_plan'
require_relative 'qm/test_result'
require_relative 'qm/test_script'

module Oslc
  # Specification:
  #   http://open-services.net/bin/view/Main/QmSpecificationV2
  #                      Test Suite -> Test Run
  #                      Test Plan -> Campaign
  #                      +---------------------------+
  #                      |                           |
  #             + ---- > |        Test Plan          |
  #             |        |  (in TMT it is Test Run)  |
  #             |        | !!! it should be Campaign |
  #             |        +---------------------------+
  #             |                    ^
  #             |                    |  Executes
  #             |                    |
  #             |        +---------------------------+       +--------------------------------+
  #             |        |        Test Case          |       |                                |
  #             |        |                           |       |          Test Script           |
  #             |        |  (in TMT it is Test Case  | ----> | (in TMT it is TestCaseVersion) |
  #  ReportsOn  |        |                           |       |                                |
  #             |        +---------------------------+       +--------------------------------+
  #             |                    ^
  #             |                    | ProducedBy
  #             |                    |
  #             |        +---------------------------+
  #             |        |                           |                 +-------------------------+
  #             |        |    Test Execution Record  |                 |                         |
  #             |        |  (in TMT it is Execution) |  -------------> |   Automation Result     |
  #             |        |    but Test Run not have  |                 | (in TMT it is Execution |
  #             |        |    the status of **new**) |                 |  which has one of the   |
  #             |        |                           |                 |  statuses as 'error',   |
  #             |        +---------------------------+                 |  'failed' and 'passed') |
  #             |                                                      +-------------------------+
  #             |                    ^
  #             |                    |
  #             +--------------------+

  module Qm
  end
end
