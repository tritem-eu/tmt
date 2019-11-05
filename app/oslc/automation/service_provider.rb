# A Service Provider describes a set of services offered by an OSLC implementation.
#
# Description:
#   http://open-services.net/bin/view/Main/OslcCoreSpecification?sortcol=table;table=up#Service_Provider_Resources
# Example:
#   http://open-services.net/bin/view/Main/AMServiceDescriptionV1
#   http://open-services.net/bin/view/Main/CmSpecificationV2Samples#Service_Provider_Samples
module Oslc
  module Automation
    class ServiceProvider < Oslc::Core::ServiceProvider

      define_query_capability do
        {
          title: "OSLC Automation - Query Automation Adapter",
          label: "Query Automation Adapter",
          query_base: @routes.query_oslc_automation_service_provider_adapters_url(@project),
          resource_shape: @routes.oslc_automation_resource_shape_url("adapter"),
          resource_type: "http://jazz.net/ns/auto/rqm#AutomationAdapterQuery"
        }
      end

      define_query_capability do
        {
          title: "Default query capability for AutomationRequest",
          label: "Query Automation Request",
          query_base: @routes.query_oslc_automation_service_provider_requests_url(@project),
          resource_shape: @routes.oslc_automation_resource_shape_url("request"),
          resource_type: "http://open-services.net/ns/auto#AutomationRequestQuery"
        }
      end

      define_query_capability do
        {
          title: "Default query capability for AutomationResult",
          label: "Query Automation Result",
          query_base: @routes.query_oslc_automation_service_provider_results_url(@project),
          resource_shape: @routes.oslc_automation_resource_shape_url("result"),
          resource_type: "http://open-services.net/ns/auto#AutomationResultQuery"
        }
      end

      define_query_capability do
        {
          title: "Default query capability for AutomationPlan",
          label: "Query Automation Plan",
          query_base: @routes.query_oslc_automation_service_provider_plans_url(@project),
          resource_shape: @routes.oslc_automation_resource_shape_url("plan"),
          resource_type: "http://open-services.net/ns/auto#AutomationPlanQuery"
        }
      end

      define_creation_factory do
        {
          title: "Default creation factory for Automation Adapter",
          creation: @routes.oslc_automation_service_provider_adapters_url(@project),
          resource_shape: @routes.oslc_automation_resource_shape_url("adapter"),
          resource_type: "http://jazz.net/ns/auto/rqm#AutomationAdapter"
        }
      end

      define_creation_factory do
        {
          title: "Default creation factory for Automation Result",
          creation: @routes.oslc_automation_service_provider_results_url(@project),
          resource_shape: @routes.oslc_automation_resource_shape_url("result"),
          resource_type: "http://jazz.net/ns/auto/rqm#AutomationResult"
        }
      end

      def after_initialize
        @resource_url = @routes.oslc_automation_service_provider_url(@project)
        @publisher_title = "TMT Quality Manager Test Automation Adapter"
        @publisher_identifier = @routes.oslc_automation_service_providers_url
        @service_domain = "http://open-services.net/ns/auto#"
      end

    end
  end
end
