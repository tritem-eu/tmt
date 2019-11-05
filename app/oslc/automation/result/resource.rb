# Specification:
#   https://jazz.net/wiki/bin/view/Main/RQMTestAutomationAdapterAPI#Automation_Adapter_Resource
module Oslc
  module Automation
    module Result
      class Resource < ::Oslc::Core::Resource

        def after_initialize
          @test_case = @object.test_case
          if @options.include?(:project)
            @project = @options[:project]
          else
            @project = @object.project
          end
          @test_run = @object.test_run

          @resource_type = 'oslc_auto:AutomationResult'
          @object_url = @routes.oslc_automation_service_provider_result_url(@project, @object)
        end

        define_namespaces do
          {
            dcterms: :dcterms,
            rdf: :rdf,
            oslc: :oslc,
            oslc_auto: :oslc_auto,
            oslc_qm: :oslc_qm,
            rqm_auto: :rqm_auto
          }
        end

        define_property "dcterms:contributor" do
          @project.members.pluck(:user_id).map do |user_id|
            url_to_define @routes.oslc_user_url(user_id)
          end
        end

        define_property 'dcterms:title' do
          string_to_define @object.comment
        end

        define_property "dcterms:creator" do
          if @test_run.executor_id
            url_to_define @routes.oslc_user_url(@test_run.executor_id)
          else
            nothing_to_define
          end
        end

        define_property 'dcterms:modified' do
          date_to_define @object.updated_at
        end

        define_property 'dcterms:created' do
          date_to_define @object.created_at
        end

        define_property 'oslc:instanceShape' do
          url_to_define @routes.oslc_automation_resource_shape_url(:result)
        end

        define_property 'oslc_auto:state' do
          execution_status = Oslc::Core::Properties::ExecutionStatus.new(@object.status)
          url_to_define execution_status.map_to_state_property
        end

        define_property 'oslc_auto:verdict' do
          execution_status = Oslc::Core::Properties::ExecutionStatus.new(@object.status)
          url_to_define execution_status.map_to_verdict_property
        end

        define_property 'oslc_auto:producedByAutomationRequest' do
          url_to_define @routes.oslc_automation_service_provider_request_url(@project, @object)
        end

        define_property 'oslc_qm:reportsOnTestCase' do
          url_to_define @routes.oslc_qm_service_provider_test_case_url(@project, @object.test_case)
        end

        define_property 'oslc:serviceProvider' do
          url_to_define @routes.oslc_automation_service_provider_url(@project)
        end

        define_property 'dcterms:identifier' do
          string_to_define @routes.oslc_automation_service_provider_result_url(@project, @object)
        end

        define_property 'oslc_auto:reportsOnAutomationPlan' do
          url_to_define @routes.oslc_automation_service_provider_plan_url(@project, @object)
        end

        define_property 'rqm_auto:executedOnMachine' do
          if @test_run.executor_id
            url_to_define @routes.oslc_user_url(@test_run.executor_id)
          else
            nothing_to_define
          end
        end

        define_property "oslc_auto:initialParameter" do
          @test_case.custom_field_values.map do |custom_field|
            define_sub_selector({}, "oslc_auto:ParameterInstance") do |handler|
              define_sub_selector(handler, "rdf:value") do |handler|
                string_to_define custom_field.value
              end
              define_sub_selector handler, "oslc:name" do |handler|
                string_to_define custom_field.custom_field_name
              end
            end
          end
        end
      end
    end
  end
end
