# Specification:
#   https://jazz.net/wiki/bin/view/Main/RQMTestAutomationAdapterAPI#Automation_Adapter_Resource
module Oslc
  module Automation
    module Adapter
      class Resource < ::Oslc::Core::Resource
        def after_initialize
          unless @cache
            @cache = Oslc::Automation::Adapter::Cache.new([@object])
          end
          @project = @cache.project
          @machine = @cache.machine_for(@object)
          @resource_type = 'rqm_auto:AutomationAdapter'
          @object_url =  @routes.oslc_automation_service_provider_adapter_url(@project, @object)
        end

        define_namespaces do
          {
            dcterms: :dcterms,
            rdf: :rdf,
            oslc: :oslc,
            rqm_auto: :rqm_auto,
            rqm_qm: :rqm_qm
          }
        end

        define_property "rqm_auto:ipAddress" do
          if @machine
            string_to_define @machine.ip_address
          else
            nothing_to_define
          end
        end

        define_property "oslc:serviceProvider" do
          url_to_define @routes.oslc_automation_service_provider_url(@project)
        end

        define_property "dcterms:creator" do
          url_to_define @routes.oslc_user_url(@object.user_id)
        end

        define_property "rqm_auto:workAvailable" do
          boolean_to_define @object.work_available.to_s
        end

        define_property "dcterms:title" do
          string_to_define @object.name
        end

        define_property "rqm_auto:assignedWorkUrl" do
          automation_adapter_url = @routes.oslc_automation_service_provider_adapter_url(@project, @object)
          url_to_define @routes.query_oslc_automation_service_provider_requests_url(@project,
            'oslc.where' => "rqm_auto:executesOnAdapter=<#{automation_adapter_url}> and rqm_auto:taken=false and oslc_auto:state!=<http://open-services.net/ns/auto#canceled>"
          )
        end

        define_property "rqm_auto:workAvailableUrl" do
          url_to_define @routes.oslc_automation_service_provider_adapter_url(@project, @object, 'oslc.properties' => 'rqm_auto:workAvailable')
        end

        define_property "dcterms:type" do
          string_to_define @object.adapter_type
        end

        define_property "rqm_auto:pollingInterval" do
          long_to_define @object.polling_interval
        end

        define_property "dcterms:modified" do
          date_to_define(@object.updated_at)
        end

        define_property "oslc:instanceShape" do
          url_to_define @routes.oslc_automation_resource_shape_url(:adapter)
        end

        define_property "rqm_auto:runsOnMachine" do
          url_to_define @routes.oslc_user_url(@object.user_id)
        end

        define_property "rqm_auto:fullyQualifiedDomainName" do
          if @machine
            string_to_define @machine.fully_qualified_domain_name
          else
            nothing_to_define
          end
        end

        define_property "dcterms:description" do
          string_to_define @object.description
        end

        define_property "rqm_auto:macAddress" do
          if @machine
            string_to_define @machine.mac_address
          else
            nothing_to_define
          end
        end

        define_property "dcterms:identifier" do
          string_to_define @routes.oslc_automation_service_provider_adapter_url(@project, @object)
        end

        define_property "rqm_auto:hostname" do
          if @machine
            string_to_define @machine.hostname
          else
            nothing_to_define
          end
        end
      end
    end
  end
end
