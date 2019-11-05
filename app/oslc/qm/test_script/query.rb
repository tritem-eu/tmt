# Automation Request Query

module Oslc
  module Qm
    module TestScript
      class Query < Oslc::Core::Query

        def after_initialize
          @class_name = ::Tmt::TestCaseVersion
          @provider = @options[:provider]
          @where = @class_name.where(test_case_id: @provider.test_case_ids)
        end

        define_property "dcterms:title" do
          {
            parser: :string,
            model_attribute: :comment
          }
        end

        define_property "dcterms:description" do
          {
            parser: :string,
            model_attribute: :comment
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

        define_property "dcterms:creator" do
          parser = lambda do |value|
            @url_parser.user_id_for(value)
          end
          {
            parser: parser,
            model_attribute: :author_id,
            query_class: Oslc::User::Query,
            joins: [:author]
          }
        end

        define_property "dcterms:identifier" do
          {
            parser: :parse_identifier,
            url_pattern: @@routes.oslc_qm_service_provider_test_script_url('*', '*'),
            model_attribute: :id
          }
        end

        define_property "oslc:instanceShape" do
          parser = lambda do |value|
            instance_shape_id = @url_parser.qm_instance_shape_id_for(value)
            instance_shape_id == 'test-script' ? :all : []
          end
          {
            parser: parser,
            model_attribute: :test_case_id
          }
        end

        define_property "oslc:serviceProvider" do
          parser = lambda do |value|
            provider_id = @url_parser.qm_service_provider_id_for(value)
            provider_id == @provider.id.to_s ? :all : []
          end
          {
            parser: parser,
            model_attribute: :test_case_id
          }
        end

        define_property "oslc_qm:executionInstructions" do
          parser = lambda do |value|
            @url_parser.download_qm_service_provider_test_script_id_for(value)
          end
          {
            parser: parser,
            model_attribute: :id
          }
        end

        define_property "dcterms:contributor" do
          parser = lambda do |value|
            user_id = @url_parser.user_id_for(value)
            if @provider.user_ids.map(&:to_s).include?(user_id)
              @provider.test_case_ids
            else
              []
            end
          end
          {
            parser: parser,
            model_attribute: :test_case_id,
            query_class: Oslc::User::Query,
            joins: [:project, :members, :user]
          }
        end

      end
    end
  end
end
