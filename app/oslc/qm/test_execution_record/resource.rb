# Specification:
#   http://open-services.net/bin/view/Main/QmSpecificationV2#Resource_TestResult
# Example:
#   http://open-services.net/bin/view/Main/QmSpecificationV2Samples#TestResult_RDF_XML
module Oslc
  module Qm
    module TestExecutionRecord
      class Resource < ::Oslc::Core::Resource
        def after_initialize
          if @cache
            @test_case = @cache.test_case_for(@object)
            @test_run = @cache.test_run_for(@object)
            @project = @cache.project
          else
            @test_case = @object.test_case
            @test_run = @object.test_run
            @project = @object.project
          end
          @resource_type = 'oslc_qm:TestExecutionRecord'
          @object_url = @routes.oslc_qm_service_provider_test_execution_record_url(@project, @object)
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
          string_to_define "Execute #{@test_case.name}"
        end

        define_property "dcterms:identifier" do
          string_to_define @routes.oslc_qm_service_provider_test_execution_record_url(@project, @object)
        end

        define_property "dcterms:creator" do
          url_to_define @routes.oslc_user_url(@test_run.creator_id)
        end

        define_property "dcterms:contributor" do
          if @test_run.executor_id
            url_to_define @routes.oslc_user_url(@test_run.executor_id)
          else
            nothing_to_define
          end
        end

        define_property "dcterms:created" do
          date_to_define @object.created_at
        end

        define_property "dcterms:modified" do
          date_to_define @object.updated_at
        end

        define_property "oslc:instanceShape" do
          url_to_define @routes.oslc_qm_resource_shape_url('test-execution-record')
        end

        define_property "oslc:serviceProvider" do
          url_to_define @routes.oslc_qm_service_provider_url(@project)
        end

        define_property 'oslc_qm:runsTestCase' do
          url_to_define @routes.oslc_qm_service_provider_test_case_url(@project, @test_case)
        end

        define_property 'oslc_qm:reportsOnTestPlan' do
          url_to_define @routes.oslc_qm_service_provider_test_plan_url(@project, @test_run)
        end

      end
    end
  end
end
