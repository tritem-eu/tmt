module Oslc
  module Automation
    module Result
      class Query < Oslc::Core::Query


        def after_initialize
          @class_name = ::Tmt::Execution
          @provider = @options[:provider]
          @where = @class_name.where(test_run_id: @provider.test_run_ids)
        end

        define_property "dcterms:modified" do
          {
            parser: :date,
            model_attribute: :updated_at
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
            url_pattern: @@routes.oslc_automation_service_provider_result_url('*', '*'),
            model_attribute: :id
          }
        end

        define_property "dcterms:title" do
          parser = lambda do |value|
            Tmt::Execution.where(comment: value).ids
          end
          {
            parser: parser,
            model_attribute: :id
          }
        end

        define_property "oslc:serviceProvider" do
          parser = lambda do |value|
            provider_id = @url_parser.automation_service_provider_id_for(value)
            provider_id == @provider.id.to_s ? :all : []
          end
          {
            parser: parser,
            model_attribute: :test_run_id
          }
        end

        define_property "oslc:instanceShape" do
          parser = lambda do |value|
            name = @url_parser.automation_instance_shape_id_for(value)
            name == 'result' ? :all : []
          end
          {
            parser: parser,
            model_attribute: :test_run_id
          }
        end

        define_property "rqm_auto:executedOnMachine" do
          parser = lambda do |value|
            user_id = @url_parser.user_id_for(value)
            Tmt::TestRun.where(executor_id: user_id).ids
          end
          {
            parser: parser,
            model_attribute: :test_run_id
          }
        end

        define_property "oslc_auto:reportsOnAutomationPlan" do
          parser = lambda do |value|
            @url_parser.automation_plan_id_for(value)
          end
          {
            parser: parser,
            model_attribute: :id,
            class_name: Oslc::Automation::Plan::Query
          }
        end

        define_property "oslc_auto:producedByAutomationRequest" do
          parser = lambda do |value|
            @url_parser.automation_request_id_for(value)
          end

          {
            parser: parser,
            model_attribute: :id,
            query_class: Oslc::Automation::Request::Query
          }
        end

        define_property "oslc_auto:state" do
          parser = lambda do |value|
            Oslc::Core::Properties::State.new(value).to_execution_statuses
          end
          {
            parser: parser,
            model_attribute: :status
          }
        end

        define_property "oslc_auto:verdict" do
          parser = lambda do |value|
            Oslc::Core::Properties::Verdict.new(value).to_execution_statuses
          end
          {
            parser: parser,
            model_attribute: :status
          }
        end

        define_property "oslc_qm:reportsOnTestCase" do
          parser = lambda do |value|
            test_case_id = @url_parser.test_case_id_for(value)
            Tmt::TestCaseVersion.where(test_case_id: test_case_id).ids
          end
          {
            parser: parser,
            model_attribute: :version_id,
            query_class: Oslc::Qm::TestCase::Query,
            joins: [:version, :test_case]
          }
        end

      end
    end
  end
end
