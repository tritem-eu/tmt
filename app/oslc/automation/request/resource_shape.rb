# A Resource Shape for Automation Request
#
# Example:
#   http://open-services.net/bin/view/Main/QmSpecificationV2Shapes?sortcol=table;up=#TestCase
module Oslc
  module Automation
    module Request
      class ResourceShape < Oslc::Core::ResourceShape

        after_initialize do
          request_uri do
            @routes.oslc_automation_resource_shape_url(:request)
          end
          title_of_shape "QM V2 Automation Request"
          resource_type 'http://jazz.net/ns/auto/rqm#AutomationRequest'
        end

        define_namespaces do
          {
            dcterms: :dcterms,
            rdf: :rdf,
            oslc: :oslc,
            oslc_qm: :oslc_qm,
            foaf: :foaf,
            rqm_auto: :rqm_auto,
            oslc_auto: :oslc_auto
          }
        end

        define_properties do
          test_script_shape_url = @routes.oslc_qm_resource_shape_url('test_script')
          test_plan_shape_url = @routes.oslc_qm_resource_shapes_url('test_plan')
          [
            [:property_definition,                 :occurs,             :read_only, :value_type,       :representation,   :range,                        :value_shape,                  :hidden, :description],
            ["rqm_auto:taken",                     "oslc:Exactly-one",  "false",    "xmls:boolean",    nil,               nil,                           nil,                           "false", "Answers whether Automation request has been picked-up by the node responsible for actual execution."],
            ["rqm_auto:executesOnAdapter",         "oslc:Zero-or-many", "true",     "oslc:Resource",   "oslc:Reference",  nil,                           nil,                           "false", "The adapter on which Automation request will execute"],
            ["oslc_auto:inputParameter",           "oslc:Zero-or-many", "true",     "oslc:Resource",   "oslc:Inline",     "oslc_auto:ParameterInstance", "oslc_auto:ParameterInstance", "false", "Input parameter passed at the creation of request. A read-only property once request is created."],
            ["dcterms:title",                      "oslc:Exactly-one",  "true",     "xmls:string",     nil,               nil,                           nil,                           "false", "Title (reference: Dublin Core) of the resource represented as rich text in XHTML content. SHOULD include only content that is valid inside an XHTML &lt;span&gt; element."],
            ["dcterms:identifier",                 "oslc:Exactly-one",  "true",     "xmls:string",     nil,               nil,                           nil,                           "true",  "A unique identifier for a resource. Assigned by the service provider when a resource is created. Not intended for end-user display."],
            ["oslc_auto:executesAutomationPlan",   "oslc:Exactly-one",  "true",     "oslc:Resource",   "oslc:Either",     "oslc_auto:AutomationPlan",    test_plan_shape_url,           "false", "Automation Plan for which request is submitted to execute"],
            ["oslc_qm:executesTestScript",         "oslc:Zero-or-one",  "true",     "oslc:Resource",   "oslc:Either",     "oslc_qm:TestScript",          test_script_shape_url,         "false", "Actual Automation resource to be executed. It is likely that the target resource will be an oslc_qm:TestScript but that is not necessarily the case."],
            ["rqm_auto:progress",                  "oslc:Exactly-one",  "false",    "xmls:integer",    nil,               nil,                           nil,                           "false", "Overall Automation progress in percentage. Valid value from 0 to 100."],
            ["oslc_auto:state",                    "oslc:Exactly-one",  "false",    "oslc:Resource",   nil,               nil,                           nil,                           "false", "Used to indicate state of the request based on values defined by the service provider."],
            ["rqm_auto:stateUrl",                  "oslc:Exactly-one",  "true",     "oslc:Resource",   nil,               nil,                           nil,                           "false", "Handy URL to query oslc_auto:state property of the Automation Request. Often client will use it to query if request has been canceled while executing the automation request"],
            ["dcterms:contributor",                "oslc:Zero-or-many", "true",     "oslc:Resource",   "oslc:Either",     "foaf:Person",                 nil,                           "false", "Contributor or contributors to resource (reference: Dublin Core). It is likely that the target resource will be an foaf:Person but that is not necessarily the case."],
            ["dcterms:creator",                    "oslc:Zero-or-many", "true",     "oslc:AnyResource", 'oslc:Either',    'foaf:Person',                 nil,                           "false", "Creator or creators of resource (reference: Dublin Core). It is likely that the target resource will be an foaf:Person but that is not necessarily the case."],
            ["dcterms:created",                    "oslc:Zero-or-one",  "true",     "rdfs:dateTime",   nil,               nil,                           nil,                           "false", "Timestamp of resource creation (reference: Dublin Core)."],
            ["oslc:instanceShape",                 "oslc:Zero-or-one",  "true",     "oslc:Resource",   'oslc:Reference',  'oslc:ResourceShape',          nil,                           "true",  "Resource Shape that provides hints as to resource property value-types and allowed values."],
            ["rdf:type",                           "oslc:Zero-or-many", "true",     "oslc:Resource",   'oslc:Reference',  'oslc_auto:AutomationRequest', nil,                           "true",  "The resource type URIs." ],
            ["dcterms:modified",                   "oslc:Zero-or-one",  "true",     "rdfs:dateTime",   nil,               nil,                           nil,                           "false", "Timestamp of latest resource modification (reference: Dublin Core)."],
            ["oslc:serviceProvider",               "oslc:Zero-or-many", "true",     "oslc:Resource",   'oslc:Reference', 'oslc:ServiceProvider',         nil,                           "true",  "The scope of a resource is a link to the resource's OSLC Service Provider."],
            ["rqm_auto:attachment",                "oslc:Exactly-one",  "true",     "oslc:Resource",   nil,               nil,                           nil,                           "false", "URL where is saved file with instructions to invoke by machine"]
          ]
        end
      end
    end
  end
end
