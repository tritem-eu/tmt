# A Resource Shape for Automation Request
#
# Example:
#   http://open-services.net/bin/view/Main/QmSpecificationV2Shapes?sortcol=table;up=#TestCase
module Oslc
  module Automation
    module Result
      class ResourceShape < Oslc::Core::ResourceShape
        define_namespaces do
          {
            dcterms: :dcterms,
            rdf: :rdf,
            oslc: :oslc,
            oslc_qm: :oslc_qm,
            oslc_auto: :oslc_auto,
            oslc_auto: :oslc_auto,
            rqm_auto: :rqm_auto
          }
        end

        after_initialize do
          request_uri do
            @routes.oslc_automation_resource_shape_url(:result)
          end

          title_of_shape "QM V2 Automation Result"
          resource_type "http://jazz.net/ns/auto/rqm#AutomationResult"
        end

        define_properties do
          test_script_shape_url = @routes.oslc_qm_resource_shape_url('test_script')
          test_plan_shape_url = @routes.oslc_qm_resource_shape_url('test_plan')
          test_case_shape_url = @routes.oslc_qm_resource_shape_url('test_case')
          test_execution_record_shape_url = @routes.oslc_qm_resource_shape_url('test_execution_record')
          automation_request_shape_url = @routes.oslc_automation_resource_shape_url('automation_request')
          [
            [:property_definition,                     :occurs,             :read_only,  :value_type,       :representation,   :range,                        :value_shape,                    :hidden, :description],
            ["dcterms:contributor",                    "oslc:Zero-or-many", "true",      "oslc:Resource",   "oslc:Reference",  "foaf:Person",                 nil,                             "false", "Contributor or contributors to resource (reference: Dublin Core). It is likely that the target resource will be an foaf:Person but that is not necessarily the case."],
            ["dcterms:creator",                        "oslc:Zero-or-many", "true",      "oslc:Resource",   "oslc:Reference",  "foaf:Person",                 nil,                             "false", "Creator or creators of resource (reference: Dublin Core). It is likely that the target resource will be an foaf:Person but that is not necessarily the case."],
            ["oslc_auto:initialParameter",             "oslc:Zero-or-many", "true",      "oslc:Resource",   "oslc:Inline",     "oslc_auto:ParameterInstance", "oslc_auto:ParameterInstance",   "false", "Input parameter passed at the creation of request. A read-only property once request is created."],
            ["rqm_auto:executedOnMachine",             "oslc:Zero-or-one",  "true",      "oslc:Resource",   "oslc:Reference",  "foaf:Person",                 nil,                             "false", "Actual machine on which execution happened"],
            ["oslc_auto:verdict",                      "oslc:Exactly-one",  "false",     "oslc:Resource",   nil,               nil,                           nil,                             "false", "Used to indicate the verdict of the Automation Result based on values defined by the service provider."],
            ["dcterms:identifier",                     "oslc:Exactly-one",  "true",      "xmls:string",     nil,               nil,                           nil,                             "true",  "A unique identifier for a resource. Assigned by the service provider when a resource is created. Not intended for end-user display."],
            ["dcterms:modified",                       "oslc:Zero-or-one",  "true",      "xmls:dateTime",   nil,               nil,                           nil,                             "false", "Timestamp of latest resource modification (reference: Dublin Core)."],
            ["rdf:type",                               "oslc:Zero-or-one",  "true",      "oslc:Resource",   "oslc:Reference",  "oslc_auto:AutomationResult",  nil,                             "true",  "The resource type URIs."],
            ["oslc_auto:producedByAutomationRequest",  "oslc:Zero-or-one",  "true" ,     "oslc:Resource",   "oslc:Reference",  "oslc_auto:AutomationRequest", automation_request_shape_url,    "false", "Automation Request which produced the Automation Result."],
            ["oslc:instanceShape",                     "oslc:Zero-or-one",  "true",      "oslc:Resource",   "oslc:Reference",  "oslc:ResourceShape",          "oslc:ResourceShape" ,           "true",  "Resource Shape that provides hints as to resource property value-types and allowed values."],
            ["dcterms:title",                          "oslc:Exactly-one",  "false",     "xmls:string",     nil,               nil,                           nil,                             "false", "Title (reference: Dublin Core) of the resource represented as rich text in XHTML content. SHOULD include only content that is valid inside an XHTML &lt;span&gt; element."],
            ["oslc_auto:state",                        "oslc:Exactly-one",  "false",     "oslc:Resource",   nil,               nil,                           nil,                             "false", "Used to indicate state of the execution based on values defined by the service provider."],
            ["dcterms:created",                        "oslc:Zero-or-one",  "true",      "xmls:dateTime",   nil,               nil,                           nil,                             "false", "Timestamp of resource creation (reference: Dublin Core)."],
            ["oslc_qm:reportsOnTestCase",              "oslc:Exactly-one",  "true",      "oslc:Resource",   "oslc:Reference",  "oslc_qm:TestCase",            test_case_shape_url,             "false", "Test Case that the Automation Result reports on. It is likely that the target resource will be an oslc_qm:TestCase but that is not necessarily the case."],
            ["oslc:serviceProvider",                   "oslc:Exactly-one",  "true",      "oslc:Resource",   "oslc:Reference",  "oslc:ServiceProvider",        "oslc:ServiceProvider",          "true",  "The scope of a resource is a link to the resource's OSLC Service Provider."],
            ["oslc_auto:reportsOnAutomationPlan",      "oslc:Exactly-one",  "true",      "oslc:Resource",   "oslc:Reference",  "oslc_auto:AutomationPlan",    test_execution_record_shape_url, "false", "Automation Plan which produced the Automation Result."],
          ]
        end
      end
    end
  end
end
