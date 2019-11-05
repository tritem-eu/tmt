# Specification:
#   https://jazz.net/wiki/bin/view/Main/RQMTestAutomationAdapterAPI#Automation_Request_Resource
module Oslc
  module Automation
    module Request
      class Resource < ::Oslc::Core::Resource
        def after_initialize
          unless @cache
            @cache = Oslc::Automation::Request::Cache.new([@object])
          end
          @project = @cache.project
          @version = @cache.version_for(@object)
          @test_case = @cache.test_case_for(@object)
          @test_run = @cache.test_run_for(@object)
          @custom_field_values = @cache.custom_field_values_for(@object)
          executor_id = @test_run.executor_id
          @adapters = @cache.adapters_for(executor_id)

          @resource_type = 'oslc_auto:AutomationRequest'
          @object_url = @routes.oslc_automation_service_provider_request_url(@project, @object)
        end

        define_namespaces do
          {
            dcterms: :dcterms,
            rdf: :rdf,
            oslc: :oslc,
            oslc_qm: :oslc_qm,
            oslc_auto: :oslc_auto,
            rqm_auto: :rqm_auto,
            rqm_qm: :rqm_qm
          }
        end

        define_property "rqm_auto:taken" do
          value = (not [nil, '', 'none'].include?(@object.status)).to_s
          boolean_to_define(value)
        end

        define_property "rqm_auto:progress" do
          long_to_define @object.progress || 0
        end

        define_property "dcterms:modified" do
          date_to_define(@object.updated_at)
        end

        define_property "dcterms:contributor" do
          if @test_run and @test_run.executor_id
            url_to_define @routes.oslc_user_url(@test_run.executor_id)
          else
            nothing_to_define
          end
        end

        define_property "dcterms:creator" do
          url_to_define @routes.oslc_user_url(@test_run.creator_id)
        end

        define_property "dcterms:title" do
          string_to_define "Execute #{@test_case.name}"
        end

        define_property "dcterms:identifier" do
          string_to_define @routes.oslc_automation_service_provider_request_url(@project, @object)
        end

        define_property "dcterms:created" do
          date_to_define(@object.created_at)
        end

        define_property "oslc:instanceShape" do
          url_to_define @routes.oslc_automation_resource_shape_url(:request)
        end

        define_property "oslc:serviceProvider" do
          url_to_define @routes.oslc_automation_service_provider_url(@project)
        end

        define_property "rqm_auto:executesOnAdapter" do
          @adapters.map do |adapter|
            url_to_define @routes.oslc_automation_service_provider_adapter_url(@project, adapter)
          end
        end

        define_property "rqm_auto:stateUrl" do
          url_to_define @routes.oslc_automation_service_provider_request_url(@project, @object, 'oslc.properties' => 'oslc_auto:state')
        end

        # documentation: http://open-services.net/wiki/automation/OSLC-Automation-Specification-Version-2.0/#Resource_AutomationResult
        # state: new, queued, inProgress, canceling, canceled, complete
        define_property "oslc_auto:state" do
          state = {
            'executing' => 'queued',
            'error' => 'complete',
            'passed' => 'complete',
            'failed' => 'complete'
          }[@object.status] || 'new'
          url_to_define "http://open-services.net/ns/auto##{state}"
        end

        define_property "oslc_auto:executesAutomationPlan" do
          url_to_define @routes.oslc_automation_service_provider_plan_url(@project, @object)
        end

        define_property "rqm_auto:attachment" do
          url_to_define @routes.download_oslc_qm_service_provider_test_script_url(@project, @version)
        end

        define_property "oslc_qm:executesTestScript" do
          url_to_define @routes.oslc_qm_service_provider_test_script_url(@project, @version)
        end

        define_property "oslc_auto:inputParameter" do
          @custom_field_values.map do |custom_field_value|
            define_sub_selector({}, "oslc_auto:ParameterInstance") do |handler|
              define_sub_selector(handler, "rdf:value") do |handler|
                string_to_define custom_field_value.value
              end
              define_sub_selector handler, "oslc:name" do |handler|
                string_to_define custom_field_value.custom_field_name
              end
            end
          end
        end
      end
    end
  end
end
