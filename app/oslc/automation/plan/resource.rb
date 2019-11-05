module Oslc
  module Automation
    module Plan
      # Specification:
      #   https://jazz.net/wiki/bin/view/Main/RQMTestAutomationAdapterAPI#Automation_Adapter_Resource
      #   In jazz.net system **Automation Plan** is named TestCaseExecutionRecords ().
      #   TCER we can find in each Test Cases.
      #   More information in app/oslc/automation.rb file
      class Resource < ::Oslc::Core::Resource
        def after_initialize
          unless @cache
            @cache = Oslc::Automation::Plan::Cache.new([@object])
          end
          @version = @cache.test_case_version_for(@object)
          @test_case = @cache.test_case_for(@object)
          @test_run = @cache.test_run_for(@object)
          @project = @cache.project

          @resource_type = 'oslc_auto:AutomationPlan'
          @object_url = @routes.oslc_automation_service_provider_plan_url(@project, @object)
        end

        define_namespaces do
          {
            dcterms: :dcterms,
            rdf: :rdf,
            oslc: :oslc,
            oslc_qm: :oslc_qm
          }
        end

        define_property "oslc_qm:runsTestCase" do
          url_to_define @routes.oslc_qm_service_provider_test_case_url(@project, @object)
        end

        define_property "dcterms:modified" do
          date_to_define @object.updated_at
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
          string_to_define @test_case.name
        end

        define_property "dcterms:identifier" do
          string_to_define @routes.oslc_automation_service_provider_plan_url(@project, @object)
        end

        define_property "dcterms:created" do
          date_to_define(@object.created_at)
        end

        define_property "oslc:instanceShape" do
          url_to_define @routes.oslc_automation_resource_shape_url(:plan)
        end

        define_property "oslc:serviceProvider" do
          url_to_define @routes.oslc_automation_service_provider_url(@project)
        end
      end
    end
  end
end
