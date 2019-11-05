# Automation Request Query

module Oslc
  module Automation
    module Request
      class Query < Oslc::Core::Query

        define_property "rqm_auto:progress" do
          {
            parser: :int,
            model_attribute: :progress
          }
        end

        define_property "dcterms:modified" do
          {
            parser: :date,
            model_attribute: :updated_at
          }
        end

        define_property "rqm_auto:taken" do
          parser = lambda do |value|
            if value == 'true'
              ['error', 'failed', 'passed', 'executing']
            else
              [nil, '', 'none']
            end
          end
          {
            parser: parser,
            model_attribute: :status
          }
        end

        define_property "oslc_auto:state" do
          parser = lambda do |value|
            ::Oslc::Core::Properties::State.new(value).to_execution_statuses
          end
          {
            parser: parser,
            model_attribute: :status
          }
        end

        define_property "dcterms:created" do
          {
            parser: :date,
            model_attribute: :created_at
          }
        end

        define_property "dcterms:identifier" do
          {
            parser: :parse_identifier,
            url_pattern: @@routes.oslc_automation_service_provider_request_url('*', '*'),
            model_attribute: :id
          }
        end

        define_property "dcterms:title" do
          parser = lambda do |value|
            name = value.gsub(/^Execute /, '')
            test_case_ids = ::Tmt::TestCase.where(name: name).ids
            ::Tmt::TestCaseVersion.where(test_case_id: test_case_ids).ids
          end

          {
            parser: parser,
            model_attribute: :version_id
          }
        end

        define_property "dcterms:creator" do
          parser = lambda do |value|
            user_id = @url_parser.user_id_for(value)
            Tmt::TestRun.where(creator_id: user_id).ids
          end
          {
            parser: parser,
            model_attribute: :test_run_id
          }
        end

        define_property "oslc_auto:executesAutomationPlan" do
          parser = lambda do |value|
            @url_parser.automation_plan_id_for(value)
          end

          {
            parser: parser,
            model_attribute: :id
          }
        end

        define_property "rqm_auto:executesOnAdapter" do
          parser = lambda do |value|
            adapter_id = @url_parser.automation_adapter_id_for(value)
            adapters = Tmt::AutomationAdapter.where(id: adapter_id)
            if adapters.size > 0
              test_runs = adapters[0].test_runs
              if test_runs
                adapters[0].test_runs.pluck(:id)
              end
            else
              []
            end
          end

          {
            parser: parser,
            model_attribute: :test_run_id
          }
        end

        define_property "oslc_qm:executesTestScript" do
          parser = lambda do |value|
            @url_parser.test_script_id_for(value)
          end
          {
            parser: parser,
            model_attribute: :version_id
          }
        end

        def after_initialize
          @class_name = ::Tmt::Execution
          @provider = @options[:provider]
          @where = @class_name.where(test_run_id: @provider.test_runs.conditions_for_automation_requests.pluck(:id))
        end

      end
    end
  end
end
