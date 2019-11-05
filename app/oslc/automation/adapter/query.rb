# Automation Request Query

module Oslc
  module Automation
    module Adapter
      class Query < Oslc::Core::Query

        define_property "dcterms:modified" do
          {
            parser: :date,
            model_attribute: :updated_at
          }
        end

        define_property "rqm_auto:fullyQualifiedDomainName" do
          parser = lambda do |value|
            Tmt::Machine.where(fully_qualified_domain_name: value).pluck(:user_id)
          end
          {
            parser: parser,
            model_attribute: :user_id
          }
        end

        define_property "rqm_auto:hostname" do
          parser = lambda do |value|
            Tmt::Machine.where(hostname: value).pluck(:user_id)
          end
          {
            parser: parser,
            model_attribute: :user_id
          }
        end

        define_property "dcterms:created" do
          {
            parser: :date,
            model_attribute: :created_at
          }
        end

        define_property "rqm_auto:pollingInterval" do
          {
            parser: :int,
            model_attribute: :polling_interval
          }
        end

        define_property "dcterms:type" do
          {
            parser: :string,
            model_attribute: :adapter_type
          }
        end

        define_property "dcterms:identifier" do
          {
            parser: :parse_identifier,
            url_pattern: @@routes.oslc_automation_service_provider_adapter_url('*', '*'),
            model_attribute: :id
          }
        end

        define_property "dcterms:title" do
          {
            parser: :string,
            model_attribute: :name
          }
        end

        define_property "rqm_auto:macAddress" do
          parser = lambda do |value|
            Tmt::Machine.where(mac_address: value).pluck(:user_id)
          end
          {
            parser: parser,
            model_attribute: :user_id
          }
        end

        define_property "dcterms:creator" do
          parser = lambda do |value|
            @url_parser.user_id_for(value)
          end
          {
            parser: parser,
            model_attribute: :user_id
          }
        end

        define_property "rqm_auto:ipAddress" do
          parser = lambda do |value|
            Tmt::Machine.where(ip_address: value).pluck(:user_id)
          end
          {
            parser: parser,
            model_attribute: :user_id
          }
        end

        define_property "rqm_auto:workAvailable" do
          parser = lambda do |value|
            test_run_ids = @provider.executions.where(status: ::Tmt::Execution::STATUS_NONE).pluck(:test_run_id)
            executor_ids = Tmt::TestRun.where(id: test_run_ids).conditions_for_automation_requests.pluck(:executor_id)
            if value == 'true'
              Tmt::Machine.where(user_id: executor_ids).pluck(:user_id)
            else
              Tmt::Machine.where.not(user_id: executor_ids).pluck(:user_id)
            end
          end
          {
            parser: parser,
            model_attribute: :user_id
          }
        end

        attr_reader :provider
        def after_initialize
          @class_name = ::Tmt::AutomationAdapter
          @provider = @options[:provider]
          @current_user = @options[:current_user]
          @where = @class_name.where(project_id: @provider.id)
        end

      end
    end
  end
end
