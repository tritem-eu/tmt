# Specification:
#   http://open-services.net/bin/view/Main/QmSpecificationV2#Resource_TestResult
# Example:
#   http://open-services.net/bin/view/Main/QmSpecificationV2Samples#TestResult_RDF_XML
module Oslc
  module Qm
    module TestResult
      class Resource < ::Oslc::Core::Resource
        def after_initialize
          unless @cache
            @cache = Oslc::Qm::TestResult::Cache.new([@object])
            @test_case = @cache.test_case_for(@object)
            @project = @test_case.project
          else
            @test_case = @cache.test_case_for(@object)
            @project = @cache.project
          end
          @resource_type = 'oslc_qm:TestResult'
          @object_url = @routes.oslc_qm_service_provider_test_result_url(@project, @object)
        end

        define_namespaces do
          {
            dcterms: :dcterms,
            foaf: :foaf,
            rdf: :rdf,
            oslc_qm: :oslc_qm,
            oslc: :oslc
          }
        end

        define_property "dcterms:title" do
          string_to_define @object.comment
        end

        define_property "dcterms:identifier" do
          string_to_define @routes.oslc_qm_service_provider_test_result_url(@project, @object)
        end

        define_property "dcterms:created" do
          date_to_define @object.created_at
        end

        define_property "dcterms:modified" do
          date_to_define @object.updated_at
        end

        define_property "oslc:instanceShape" do
          url_to_define @routes.oslc_qm_resource_shape_url('test-result')
        end

        define_property "oslc:serviceProvider" do
          url_to_define @routes.oslc_qm_service_provider_url(@project)
        end

        define_property 'oslc_qm:status' do
          execution_status = Oslc::Core::Properties::ExecutionStatus.new(@object.status)
          url_to_define execution_status.map_to_state_property
        end

        define_property 'oslc_qm:executesTestScript' do
          url_to_define @routes.oslc_qm_service_provider_test_script_url(@project, @object.version_id)
        end

        define_property 'oslc_qm:producedByTestExecutionRecord' do
          url_to_define @routes.oslc_qm_service_provider_test_execution_record_url(@project, @object)
        end

        define_property 'oslc_qm:reportsOnTestCase' do
          url_to_define @routes.oslc_qm_service_provider_test_case_url(@project, @test_case)
        end

        define_property 'oslc_qm:reportsOnTestPlan' do
          url_to_define @routes.oslc_qm_service_provider_test_plan_url(@project, @object)
        end

      end
    end
  end
end
