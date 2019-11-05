# A Resource Shape
#
# Example:
#   http://open-services.net/bin/view/Main/QmSpecificationV2Shapes?sortcol=table;up=#TestScript
# Status: Checked
module Oslc
  module Qm
    module TestScript
      class ResourceShape < Oslc::Core::ResourceShape
        define_namespaces do
          {
            dcterms: :dcterms,
            rdf: :rdf,
            oslc: :oslc,
            oslc_qm: :oslc_qm,
            foaf: :foaf
          }
        end

        after_initialize do
          request_uri do
            @routes.oslc_qm_resource_shape_url('test-script')
          end

          title_of_shape 'QM V2 Test Script'

          resource_type "http://open-services.net/ns/qm#TestScript"
        end

        define_properties do
          [
            [:property_definition,            :occurs,             :read_only,  :value_type,        :representation,  :range,                  :value_shape,  :hidden, :description],
            ["dcterms:contributor",           "oslc:Zero-or-many", "false",     "oslc:AnyResource", 'oslc:Either',    'foaf:Person',           nil,           "false", "Contributor or contributors to resource (reference: Dublin Core). It is likely that the target resource will be an foaf:Person but that is not necessarily the case."],
            ["dcterms:created",               "oslc:Zero-or-one",  "true",      "rdfs:dateTime",    nil,              nil,                     nil,           "false", "Timestamp of resource creation (reference: Dublin Core)."],
            ["dcterms:creator",               "oslc:Zero-or-many", "true",      "oslc:AnyResource", 'oslc:Either',    'foaf:Person',           nil,           "false", "Creator or creators of resource (reference: Dublin Core). It is likely that the target resource will be an foaf:Person but that is not necessarily the case."],
            ["dcterms:description",           "oslc:Zero-or-one",  "false",     "rdf:XMLLiteral",   nil,              nil,                     nil,           "false", "Descriptive text (reference: Dublin Core) about resource represented as rich text in XHTML content. SHOULD include only content that is valid and suitable inside an XHTML &lt;div&gt; element. SHOULD include only content that is valid inside an XHTML &lt;span&gt; element."],
            ["dcterms:identifier",            "oslc:Exactly-one",  "true",      "rdf:string",       nil,              nil,                     nil,           "true",  "A unique identifier for a resource. Assigned by the service provider when a resource is created. Not intended for end-user display."],
            ["dcterms:modified",              "oslc:Zero-or-one",  "true",      "rdfs:dateTime",    nil,              nil,                     nil,           "false", "Timestamp of latest resource modification (reference: Dublin Core)."],
            ["rdf:type",                      "oslc:Zero-or-many", "true",      "oslc:Resource",    'oslc:Reference', 'oslc_qm:TestPlan',      nil,           "true",  "The resource type URIs." ],
            ["dcterms:title",                 "oslc:Exactly-one",  "false",     "rdf:XMLLiteral",   nil,              nil,                     nil,           "false", "Title (reference: Dublin Core) of the resource represented as rich text in XHTML content. SHOULD include only content that is valid inside an XHTML &lt;span&gt; element."],
            ["oslc:instanceShape",            "oslc:Zero-or-one",  "true",      "oslc:Resource",    'oslc:Reference', 'oslc:ResourceShape',    nil,           "true",  "Resource Shape that provides hints as to resource property value-types and allowed values."],
            ["oslc:serviceProvider",          "oslc:Zero-or-many", "true",      "oslc:Resource",    'oslc:Reference', 'oslc:ServiceProvider',  nil,           "true",  "The scope of a resource is a link to the resource's OSLC Service Provider."],
            ["oslc_qm:executionInstructions", "oslc:Zero-or-many", "true",      "oslc:Resource",    'oslc:Reference', nil,                     nil,           "false", "Instructions for executing the test script. Note that the value of Occurs is undefined. The resource shape document provided by the QM service provider may be consulted for its value."],
            ["oslc_qm:relatedChangeRequest",  "oslc:Zero-or-many", "false",     "oslc:Resource",    'oslc:Reference', 'oslc_cm:ChangeRequest', nil,           "false", "A related change request. It is likely that the target resource will be an oslc_cm:ChangeRequest but that is not necessarily the case."],
            ["oslc_qm:validatesRequirement",  "oslc:Zero-or-many", "false",     "oslc:Resource",    'oslc:Reference', 'oslc_rm:Requirement',   nil,           "false", "Requirement that is validated by the Test Case. It is likely that the target resource will be an oslc_rm:Requirement but that is not necessarily the case."]
          ]
        end
      end
    end
  end
end
