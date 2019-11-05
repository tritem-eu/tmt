# A Resource Shape for Automation Plan
# Automation Plan has the same ResourceShaple like Test Plan !
module Oslc
  module Automation
    module Plan
      class ResourceShape < Oslc::Core::ResourceShape
        define_namespaces do
          {
            dcterms: :dcterms,
            rdf: :rdf,
            oslc: :oslc,
            oslc_qm: :oslc_qm,
            foaf: :foaf,
            rqm_auto: :rqm_auto,
            rqm_qm: :rqm_qm,
            oslc_auto: :oslc_auto
          }
        end

        after_initialize do
          request_uri do
            @routes.oslc_automation_resource_shape_url(:plan)
          end

          title_of_shape "QM V2 Automation Plan"

          resource_type 'http://jazz.net/ns/auto/rqm#AutomationPlan'

        end

        define_properties do
          test_case_shape_url = @routes.oslc_qm_resource_shape_url('test_case')
          test_plan_shape_url = @routes.oslc_qm_resource_shape_url('test_plan')
          [
            [:property_definition,             :occurs,             :read_only,  :value_type,       :representation,   :range,                       :value_shape,                  :hidden, :description],
            ["dcterms:title",                  "oslc:Exactly-one",  "true",      "xmls:string",     nil,               nil,                          nil,                           "false",  "Title (reference: Dublin Core) of the resource represented as rich text in XHTML content. SHOULD include only content that is valid inside an XHTML &lt;span&gt; element."],
            ["oslc:serviceProvider",           "oslc:Exactly-one",  "true",      "oslc:Resource",   "oslc:Reference",  "oslc:ServiceProvider",       "oslc:ServiceProvider",        "true",  "The scope of a resource is a link to the resource's OSLC Service Provider."],
            ["oslc:instanceShape",             "oslc:Zero-or-one",  "true",      "oslc:Resource",   "oslc:Reference",  "oslc:ResourceShape",         "oslc:ResourceShape" ,         "true",  "Resource Shape that provides hints as to resource property value-types and allowed values."],
            ["dcterms:contributor",            "oslc:Zero-or-many", "true",      "oslc:Resource",   "oslc:Either",     "foaf:Person",                nil,                           "false",  "Contributor or contributors to resource (reference: Dublin Core). It is likely that the target resource will be an foaf:Person but that is not necessarily the case."],
            ['oslc_qm:runsTestCase',           "oslc:Exactly-one",  "true",      "oslc:Resource",   'oslc:Either',     'oslc_qm:TestCase',           test_case_shape_url,           'false',  'Test Case run by the Automation Plan. It is likely that the target resource will be an oslc_qm:TestCase but that is not necessarily the case.'],
            ["dcterms:created",                "oslc:Zero-or-one",  "true",      "xmls:dateTime",   nil,               nil,                          nil,                           "false", "Timestamp of resource creation (reference: Dublin Core)."],
            ["dcterms:identifier",             "oslc:Exactly-one",  "true",      "xmls:string",     nil,               nil,                          nil,                           "true",  "A unique identifier for a resource. Assigned by the service provider when a resource is created. Not intended for end-user display."],
            ["dcterms:creator",                "oslc:Zero-or-many", "true",      "oslc:Resource",   "oslc:Reference",  "foaf:Person",                nil,                           "false", "Creator or creators of resource (reference: Dublin Core). It is likely that the target resource will be an foaf:Person but that is not necessarily the case."],
            ["dcterms:modified",               "oslc:Zero-or-one",  "true",      "xmls:dateTime",   nil,               nil,                          nil,                           "false", "Timestamp of latest resource modification (reference: Dublin Core)."]
          ]
        end
      end
    end
  end
end
