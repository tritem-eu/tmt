module Oslc
  module Qm
    module TestResult
      class Query < Oslc::Core::Query
        def after_initialize
          @class_name = ::Tmt::Execution
          @provider = @options[:provider]
          @where = @class_name.where(test_run_id: @provider.test_run_ids)
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

        define_property "oslc_qm:status" do
          parser = lambda do |value|
            Oslc::Core::Properties::State.new(value).to_execution_statuses
          end
          {
            parser: parser,
            model_attribute: :status
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
            url_pattern: @@routes.oslc_qm_service_provider_test_result_url('*', '*'),
            model_attribute: :id
          }
        end

        define_property "oslc_qm:reportsOnTestPlan" do
          parser = lambda do |value|
            @url_parser.test_plan_id_for(value)
          end
          {
            parser: parser,
            model_attribute: :id
          }
        end

        define_property "oslc_qm:producedByTestExecutionRecord" do
          parser = lambda do |value|
            @url_parser.test_execution_record_id_for(value)
          end
          {
            parser: parser,
            model_attribute: :id
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

        define_property "oslc_qm:reportsOnTestCase" do
          parser = lambda do |value|
            test_case_id = @url_parser.test_case_id_for(value)
            test_case = Tmt::TestCase.where(id: test_case_id).first
            if test_case
              test_case.version_ids
            else
              []
            end
          end
          {
            parser: parser,
            model_attribute: :version_id
          }
        end

        define_property "oslc:instanceShape" do
          parser = lambda do |value|
            instance_shape_id = @url_parser.qm_instance_shape_id_for(value)
            instance_shape_id == 'test-result' ? :all : []
          end
          {
            parser: parser,
            model_attribute: :test_run_id
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

      end
    end
  end
end
