# A Resource Shape
#
# Example:
#   http://open-services.net/bin/view/Main/QmSpecificationV2Shapes?sortcol=table;up=#TestCase
# Status: Checked
module Oslc
  module Qm
    module TestCase
      class ResourceShape < Oslc::Core::ResourceShape
        def resource_shape_url(name)
          @routes.oslc_qm_resource_shape_url(name)
        end

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
            @routes.oslc_qm_resource_shape_url('test-case')
          end

          title_of_shape 'QM V2 Test Case'

          resource_type 'http://open-services.net/ns/qm#TestCase'
        end

        define_properties do
          [
            [:property_definition,             :occurs,             :read_only, :value_type,        :representation,  :range,                  :value_shape,                      :hidden, :description],
            ["dcterms:contributor",            "oslc:Zero-or-many", "true",     "oslc:AnyResource", 'oslc:Either',    'foaf:Person',           nil,                               "false", "Contributor or contributors to resource (reference: Dublin Core). It is likely that the target resource will be an foaf:Person but that is not necessarily the case."],
            ["dcterms:created",                "oslc:Zero-or-one",  "true",     "rdfs:dateTime",    nil,              nil,                     nil,                               "false", "Timestamp of resource creation (reference: Dublin Core)."],
            ["dcterms:creator",                "oslc:Exactly-one",  "true",     "oslc:AnyResource", 'oslc:Either',    'foaf:Person',           nil,                               "false", "Creator or creators of resource (reference: Dublin Core). It is likely that the target resource will be an foaf:Person but that is not necessarily the case."],
            ["dcterms:description",            "oslc:Zero-or-one",  "false",    "rdf:XMLLiteral",   nil,              nil,                     nil,                               "false", "Descriptive text (reference: Dublin Core) about resource represented as rich text in XHTML content. SHOULD include only content that is valid and suitable inside an XHTML &lt;div&gt; element. SHOULD include only content that is valid inside an XHTML &lt;span&gt; element."],
            ["dcterms:identifier",             "oslc:Exactly-one",  "true",     "rdf:string",       nil,              nil,                     nil,                               "true",  "A unique identifier for a resource. Assigned by the service provider when a resource is created. Not intended for end-user display."],
            ["dcterms:modified",               "oslc:Zero-or-one",  "true",     "rdfs:dateTime",    nil,              nil,                     nil,                               "false", "Timestamp of latest resource modification (reference: Dublin Core)."],
            ["rdf:type",                       "oslc:Exactly-one",  "true",     "oslc:Resource",    'oslc:Reference', 'oslc_qm:TestPlan',      nil,                               "true",  "The resource type URIs." ],
            ["dcterms:title",                  "oslc:Exactly-one",  "false",    "rdf:XMLLiteral",   nil,              nil,                     nil,                               "false", "Title (reference: Dublin Core) of the resource represented as rich text in XHTML content. SHOULD include only content that is valid inside an XHTML &lt;span&gt; element."],
            ["oslc:instanceShape",             "oslc:Zero-or-one",  "true",     "oslc:Resource",    'oslc:Reference', 'oslc:ResourceShape',    nil,                               "true",  "Resource Shape that provides hints as to resource property value-types and allowed values."],
            ["oslc:serviceProvider",           "oslc:Exactly-one",  "true",     "oslc:Resource",    'oslc:Reference', 'oslc:ServiceProvider',  nil,                               "true",  "The scope of a resource is a link to the resource's OSLC Service Provider."],
            ["oslc_qm:usesTestScript",         "oslc:Zero-or-many", "true",     "oslc:Resource",    'oslc:Either',    'oslc_qm:TestScript',    resource_shape_url('test-script'), "false", "Test Script used by the Test Case. It is likely that the target resource will be an oslc_qm:TestScript but that is not necessarily the case."]
          ]
        end
      end
    end
  end
end
