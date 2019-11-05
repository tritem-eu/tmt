# A Resource Shape
# http://open-services.net/pub/Main/QmSpecV2Issues/QM_Resource_Shapes.txt#
# Example:
#   http://open-services.net/bin/view/Main/QmSpecificationV2Shapes?sortcol=table;up=#TestResult
# Status: Checked
module Oslc
  module Qm
    module TestResult
      class ResourceShape < Oslc::Core::ResourceShape

        define_namespaces do
          {
            dcterms: :dcterms,
            rdf: :rdf,
            oslc: :oslc,
            oslc_qm: :oslc_qm,
            oslcev_qm: :oslc_qm,
            oslc_cm: :oslc_cm,
            foaf: :foaf
          }
        end

        after_initialize do
          request_uri do
            @routes.oslc_qm_resource_shape_url('test-result')
          end

          title_of_shape 'QM V2 Test Result'

          resource_type 'http://open-services.net/ns/qm#TestPlan'

        end

        define_properties do
          test_plan_shape_url = @routes.oslc_qm_resource_shape_url('test-plan')
          test_script_shape_url = @routes.oslc_qm_resource_shape_url('test-script')
          test_case_shape_url = @routes.oslc_qm_resource_shape_url('test-case')
          test_execution_record_shape_url = @routes.oslc_qm_resource_shape_url('test-execution-record')

          [
            [:property_definition,                    :occurs,             :read_only,  :value_type,        :representation,   :range,                       :value_shape,                    :hidden, :description],
            ["dcterms:created",                       "oslc:Zero-or-one",  "true",      "rdfs:dateTime",    nil,               nil,                          nil,                             "false", "Timestamp of resource creation (reference: Dublin Core)."],
            ["dcterms:identifier",                    "oslc:Exactly-one",  "true",      "rdfs:string",      nil,               nil,                          nil,                             "true",  "A unique identifier for a resource. Assigned by the service provider when a resource is created. Not intended for end-user display."],
            ["dcterms:modified",                      "oslc:Zero-or-one",  "true",      "rdfs:dateTime",    nil,               nil,                          nil,                             "false", "Timestamp of latest resource modification (reference: Dublin Core)."],
            ["rdf:type",                              "oslc:Zero-or-many", "true",      "oslc:Resource",    'oslc:Reference',  nil,                          nil,                             "true",  "The resource type URIs." ],
            ["dcterms:title",                         "oslc:Exactly-one",  "false",     "rdf:XMLLiteral",   nil,               nil,                          nil,                             "false", "Title (reference: Dublin Core) of the resource represented as rich text in XHTML content. SHOULD include only content that is valid inside an XHTML &lt;span&gt; element."],
            ["oslc:instanceShape",                    "oslc:Zero-or-one",  "true",      "oslc:Resource",    'oslc:Reference',  'oslc:ResourceShape',         nil,                             "true",  "Resource Shape that provides hints as to resource property value-types and allowed values."],
            ["oslc:serviceProvider",                  "oslc:Zero-or-many", "true",      "oslc:Resource",    'oslc:Reference',  'oslc:ServiceProvider',       nil,                             "true",  "The scope of a resource is a link to the resource's OSLC Service Provider."],
            ["oslc_qm:status",                        "oslc:Zero-or-one",  "false",     "rdfs:string",      nil,               nil,                          nil,                             "false", "Used to indicate the state of the Test Result based on values defined by the service provider. Most often a read-only property."],
            ['oslc_qm:affectedByChangeRequest',       "oslc:Zero-or-many", "false",     "oslc:Resource",    'oslc:Reference',  'oslc_cm:ChangeRequest',      nil,                             'false', 'Change request that affects the Test Result. It is likely that the target resource will be an oslc_cm:ChangeRequest but that is not necessarily the case.'],
            ['oslc_qm:executesTestScript',            "oslc:Zero-or-one",  "false",     "oslc:Resource",    'oslc:Either',     'oslc_qm:TestScript',         test_script_shape_url,           'false', 'Test Script executed to produce the Test Result. It is likely that the target resource will be an oslc_qm:TestScript but that is not necessarily the case.'],
            ['oslc_qm:producedByTestExecutionRecord', "oslc:Zero-or-one",  "false",     "oslc:Resource",    'oslc:Either',     'oslc_qm:TestExecutionRecord',test_execution_record_shape_url, 'false', 'Test Execution Record that the Test Result was produced by. It is likely that the target resource will be an oslc_qm:TestExecutionRecord but that is not necessarily the case.'],
            ['oslc_qm:reportsOnTestCase',             "oslc:Exactly-one",  "false",     "oslc:Resource",    'oslc:Either',     'oslc_qm:TestCase',           test_case_shape_url,             'false', 'Test Case that the Test Result reports on. It is likely that the target resource will be an oslc_qm:TestCase but that is not necessarily the case.'],
            ['oslc_qm:reportsOnTestPlan',             "oslc:zero-or-one",  "true",      "oslc:Resource",    'oslc:Either',     'oslc_qm:TestPlan',           test_plan_shape_url,             'false', 'Test Plan that the Test Result reports on. It is likely that the target resource will be an oslc_qm:TestPlan but that is not necessarily the case.']
          ]
        end
      end
    end
  end
end
