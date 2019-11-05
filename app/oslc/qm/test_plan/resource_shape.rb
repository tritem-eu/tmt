# A Resource Shape
# http://open-services.net/pub/Main/QmSpecV2Issues/QM_Resource_Shapes.txt#
# Example:
#   http://open-services.net/bin/view/Main/QmSpecificationV2Shapes?sortcol=table;up=#TestPlan
# Status: Checked
module Oslc
  module Qm
    module TestPlan
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
            oslcev_qm: :oslc_qm,
            foaf: :foaf
          }
        end

        after_initialize do
          request_uri do
            @routes.oslc_qm_resource_shape_url('test-plan')
          end

          title_of_shape 'QM V2 Test Plan'

          resource_type 'http://open-services.net/ns/qm#TestPlan'
        end

        define_properties do
          [
            [:property_definition,                 :occurs,             :read_only,  :value_type,        :representation,   :range,                           :value_shape,                      :hidden, :description],
            ["dcterms:contributor",                "oslc:Zero-or-many", "false",     "oslc:AnyResource", 'oslc:Either',     'foaf:Person',                    nil,                               "false", "Contributor or contributors to resource (reference: Dublin Core). It is likely that the target resource will be an foaf:Person but that is not necessarily the case."],
            ['oslcev_qm:usesTestPlanCustomField',  "oslc:Zero-or-many", "true",      "oslc:Resource",    'oslc:Reference',  'oslcev_qm:TestPlanCustomField',  nil,                               'false', ''],
            ["dcterms:created",                    "oslc:Zero-or-one",  "true",      "rdfs:dateTime",    nil,               nil,                              nil,                               "false", "Timestamp of resource creation (reference: Dublin Core)."],
            ["dcterms:creator",                    "oslc:Zero-or-many", "true",      "oslc:AnyResource", 'oslc:Either',     'foaf:Person',                    nil,                               "false", "Creator or creators of resource (reference: Dublin Core). It is likely that the target resource will be an foaf:Person but that is not necessarily the case."],
            ["dcterms:description",                "oslc:Zero-or-one",  "false",     "rdf:XMLLiteral",   nil,               nil,                              nil,                               "false", "Descriptive text (reference: Dublin Core) about resource represented as rich text in XHTML content. SHOULD include only content that is valid and suitable inside an XHTML &lt;div&gt; element. SHOULD include only content that is valid inside an XHTML &lt;span&gt; element."],
            ["dcterms:identifier",                 "oslc:Exactly-one",  "true",      "rdfs:string",      nil,               nil,                              nil,                               "true",  "A unique identifier for a resource. Assigned by the service provider when a resource is created. Not intended for end-user display."],
            ["dcterms:modified",                   "oslc:Zero-or-one",  "true",      "rdfs:dateTime",    nil,               nil,                              nil,                               "false", "Timestamp of latest resource modification (reference: Dublin Core)."],
            ["rdf:type",                           "oslc:Zero-or-many", "true",      "oslc:Resource",    'oslc:Reference',  'oslc_qm:TestPlan',               nil,                               "true",  "The resource type URIs." ],
            ["dcterms:subject",                    "oslc:Zero-or-many", "false",     "rdfs:string",      nil,               nil,                              nil,                               "false", "Tag or keyword for a resource. Each occurrence of a dc:subject property denotes an additional tag for the resource."],
            ["dcterms:title",                      "oslc:Exactly-one",  "false",     "rdf:XMLLiteral",   nil,               nil,                              nil,                               "false", "Title (reference: Dublin Core) of the resource represented as rich text in XHTML content. SHOULD include only content that is valid inside an XHTML &lt;span&gt; element."],
            ["oslc:instanceShape",                 "oslc:Zero-or-one",  "true",      "oslc:Resource",    'oslc:Reference',  'oslc:ResourceShape',             nil,                               "true",  "Resource Shape that provides hints as to resource property value-types and allowed values."],
            ["oslc:serviceProvider",               "oslc:Zero-or-many", "true",      "oslc:Resource",    'oslc:Reference',  'oslc:ServiceProvider',           nil,                               "true",  "The scope of a resource is a link to the resource's OSLC Service Provider."],
            ["oslc_qm:relatedChangeRequest",       "oslc:Zero-or-many", "false",     "oslc:Resource",    'oslc:Reference',  'oslc_cm:ChangeRequest',          nil,                               "false", "A related change request. It is likely that the target resource will be an oslc_cm:ChangeRequest but that is not necessarily the case."],
            ["oslc_qm:usesTestCase",               "oslc:Zero-or-many", "false",     "oslc:Resource",    'oslc:Either',     'oslc_qm:TestCase',               resource_shape_url('test-case')  , "false", "Test Case used by the Test Plan. It is likely that the target resource will be an oslc_qm:TestCase but that is not necessarily the case."],
            ["oslc_qm:status",                     "oslc:Zero-or-one",  "true",      "rdfs:string",      nil,               nil,                              nil,                               "false", "Status of the Test Plan"],
            ['oslcev_qm:usesTestResult',           "oslc:Zero-or-many", "true",      "oslc:Resource",    'oslc:Either',     'oslc_qm:TestResult',             resource_shape_url('test-result'), 'false', '']
          ]
        end
      end
    end
  end
end
