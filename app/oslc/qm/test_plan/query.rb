# Automation Request Query

module Oslc
  module Qm
    module TestPlan
      class Query < Oslc::Core::Query

        define_property "dcterms:title" do
          {
            parser: :string,
            model_attribute: :name
          }
        end

        define_property "dcterms:description" do
          {
            parser: :string,
            model_attribute: :description
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
            url_pattern: @@routes.oslc_qm_service_provider_test_plan_url('*', '*'),
            model_attribute: :id
          }
        end

        define_property "oslc:serviceProvider" do
          parser = lambda do |value|
            provider_id = @url_parser.qm_service_provider_id_for(value)
            provider_id == @provider.id.to_s ? :all : 0
          end
          {
            parser: parser,
            model_attribute: :campaign_id
          }
        end

        define_property "oslc:instanceShape" do
          parser = lambda do |value|
            instance_shape_id = @url_parser.qm_instance_shape_id_for(value)
            instance_shape_id == 'test-plan' ? :all : 0
          end
          {
            parser: parser,
            model_attribute: :campaign_id
          }
        end

        define_property "oslc_qm:usesTestCase" do
          parser = lambda do |value|
            test_case_id = @url_parser.test_case_id_for(value)
            test_cases = Tmt::TestCase.where(id: test_case_id)
            unless test_cases.empty?
              test_cases.first.test_run_ids
            else
              []
            end
          end
          {
            parser: parser,
            model_attribute: :id,
            query_class: Oslc::Qm::TestCase::Query,
            joins: [:execution, :versions, :test_cases]
          }
        end

        define_property "dcterms:creator" do
          parser = lambda do |value|
            @url_parser.user_id_for(value)
          end
          {
            parser: parser,
            model_attribute: :creator_id,
            query_class: Oslc::User::Query,
            joins: [:creator]
          }
        end

        define_property "dcterms:contributor" do
          parser = lambda do |value|
            user_id = @url_parser.user_id_for(value)
            if @provider.user_ids.map(&:to_s).include?(user_id)
              :all
            else
              []
            end
          end
          {
            parser: parser,
            model_attribute: :id,
            query_class: Oslc::User::Query,
            joins: [:campaign, :project, :members, :user]
          }
        end

        def after_initialize
          @class_name = ::Tmt::TestRun
          @provider = @options[:provider]
          campaign = Tmt::Campaign.arel_table
          @where = @class_name.joins(:campaign).undeleted.where(campaign[:project_id].eq(@provider.id))
        end

      end
    end
  end
end
