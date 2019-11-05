# Automation Request Query

module Oslc
  module Automation
    module Plan
      class Query < Oslc::Core::Query

        def after_initialize
          @class_name = ::Tmt::Execution
          @provider = @options[:provider]
          @where = @class_name.where(test_run_id: @provider.test_run_ids)
        end

        define_property "oslc_qm:runsTestCase" do
          parser = lambda do |value|
            test_case_id = @url_parser.test_case_id_for(value)
            Tmt::TestCase.find(test_case_id).version_ids
          end
          {
            parser: parser,
            model_attribute: :version_id
          }
        end

        define_property "dcterms:contributor" do
          parser = lambda do |value|
            user_id = @url_parser.user_id_for(value)
            user_ids = @provider.members.pluck(:user_id)
            user_ids.empty? ? [] : :all
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

        define_property "dcterms:title" do
          parser = lambda do |value|
            test_case_ids = Tmt::TestCase.where(name: value).ids
            Tmt::TestCaseVersion.where(test_case_id: test_case_ids).ids
          end
          {
            parser: parser,
            model_attribute: :version_id
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
            url_pattern: @@routes.oslc_automation_service_provider_plan_url('*', '*'),
            model_attribute: :id
          }
        end

      end
    end
  end
end
