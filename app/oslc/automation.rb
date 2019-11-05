require_relative 'automation/service_provider_catalog'
require_relative 'automation/service_provider'

require_relative 'automation/adapter'
require_relative 'automation/adapter/cache'
require_relative 'automation/adapter/resource'
require_relative 'automation/adapter/creation_factory'
require_relative 'automation/adapter/query'
require_relative 'automation/adapter/resources'
require_relative 'automation/adapter/resource_shape'

require_relative 'automation/plan'
require_relative 'automation/plan/cache'
require_relative 'automation/plan/resource'
require_relative 'automation/plan/resource_shape'
require_relative 'automation/plan/query'
require_relative 'automation/plan/resources'

require_relative 'automation/request'
require_relative 'automation/request/resource'
require_relative 'automation/request/cache'
require_relative 'automation/request/resource_shape'
require_relative 'automation/request/modify'
require_relative 'automation/request/query'
require_relative 'automation/request/resources'

require_relative 'automation/result'
require_relative 'automation/result/resource'
require_relative 'automation/result/resource_shape'
require_relative 'automation/result/creation_factory'
require_relative 'automation/result/query'
require_relative 'automation/result/resources'

# This module joins Automation resources for 2.0 version
# Specification:
#   https://jazz.net/wiki/bin/view/Main/RQMTestAutomationAdapterAPI
#   http://open-services.net/wiki/automation/OSLC-Automation-Specification-Version-2.0/
#                      +---------------------------+
#                      |                           |
#             + ---- > |      Automation Plan      |
#             |        |  (in TMT it is Execution) |
#             |        |                           |
#             |        +---------------------------+
#             |                    ^
#             |                    |  Executes
#             |                    |
#             |        +---------------------------+       +----------------+
#             |        |                           |       |                |
#             |        |    Automation Request     |       |  Automation    |
#             |        |  (in TMT it is Execution  | ----> |  Adapter       |
#  ReportsOn  |        |   but Test Run not have   |       |                |
#             |        |   the status of **new**   |       +----------------+
#             |        |   and 'due_date' is older |
#             |        |     than current date)    |
#             |        +---------------------------+
#             |                    ^
#             |                    | ProducedBy
#             |                    |
#             |        +---------------------------+
#             |        |                           |
#             |        |    Automation Result      |
#             |        |  (in TMT it is Execution  |
#             |        |   which has one of the    |
#             |        |   statuses as 'error',    |
#             |        |   'failed' and 'passed')  |
#             |        |                           |
#             |        +---------------------------+
#             |                    ^
#             |                    |
#             +--------------------+

module Oslc
  module Automation

  end
end
