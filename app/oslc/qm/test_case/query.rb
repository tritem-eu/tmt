# Automation Request Query

module Oslc
  module Qm
    module TestCase
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
            url_pattern: @@routes.oslc_qm_service_provider_test_case_url('*', '*'),
            model_attribute: :id
          }
        end

        define_property "oslc:serviceProvider" do
          parser = lambda do |value|
            provider_id = @url_parser.qm_service_provider_id_for(value)
            if provider_id == @provider.id.to_s
              @provider.id
            else
              0
            end
          end
          {
            parser: parser,
            model_attribute: :project_id
          }
        end

        define_property "oslc:instanceShape" do
          parser = lambda do |value|
            instance_shape_id = @url_parser.qm_instance_shape_id_for(value)
            if instance_shape_id == 'test-case'
              @provider.id
            else
              0
            end
          end
          {
            parser: parser,
            model_attribute: :project_id
          }
        end

        define_property "oslc_qm:usesTestScript" do
          parser = lambda do |value|
            version_id = @url_parser.test_script_id_for(value)
            Tmt::TestCaseVersion.where(id: version_id).pluck(:test_case_id)
          end
          {
            parser: parser,
            model_attribute: :id,
            query_class: Oslc::Qm::TestScript::Query,
            joins: [:versions]
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
              @provider.test_case_ids
            else
              []
            end
          end
          {
            parser: parser,
            model_attribute: :id,
            query_class: Oslc::User::Query,
            joins: [:project, :members, :user]
          }
        end

        def after_initialize
          @class_name = ::Tmt::TestCase
          @provider = @options[:provider]
          @where = @class_name.undeleted.where(project_id: @provider.id)
        end

      end
    end
  end
end
