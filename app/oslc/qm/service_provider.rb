# A Service Provider describes a set of services offered by an OSLC implementation.
#
# Description:
#   http://open-services.net/bin/view/Main/OslcCoreSpecification?sortcol=table;table=up#Service_Provider_Resources
# Example:
#   http://open-services.net/bin/view/Main/AMServiceDescriptionV1
module Oslc
  module Qm
    class ServiceProvider < Oslc::Core::ServiceProvider
      define_query_capability do
        {
          title: "OSLC QM - Query Test Plan",
          label: "Query Test Plan",
          query_base: @routes.query_oslc_qm_service_provider_test_plans_url(@project),
          resource_shape: @routes.oslc_qm_resource_shape_url("test-run"),
          resource_type: "http://open-services.net/ns/qm#TestPlanQuery"
        }
      end

      define_query_capability do
        {
          title: "OSLC QM - Query Test Execution Record",
          label: "Query Test Execution Record",
          query_base: @routes.query_oslc_qm_service_provider_test_execution_records_url(@project),
          resource_shape: @routes.oslc_qm_resource_shape_url("test-execution-record"),
          resource_type: "http://open-services.net/ns/qm#TestExecutionRecordQuery"
        }
      end

      define_query_capability do
        {
          title: "OSLC QM - Query Test Case",
          label: "Query Test Case",
          query_base: @routes.query_oslc_qm_service_provider_test_cases_url(@project),
          resource_shape: @routes.oslc_qm_resource_shape_url("test-case"),
          resource_type: "http://open-services.net/ns/qm#TestCaseQuery"
        }
      end

      define_query_capability do
        {
          title: "OSLC QM - Query Test Script",
          label: "Query Test Script",
          query_base: @routes.query_oslc_qm_service_provider_test_scripts_url(@project),
          resource_shape: @routes.oslc_qm_resource_shape_url("test-script"),
          resource_type: "http://open-services.net/ns/qm#TestScriptQuery"
        }
      end

      define_query_capability do
        {
          title: "OSLC QM - Query Test Result",
          label: "Query Test Result",
          query_base: @routes.query_oslc_qm_service_provider_test_results_url(@project),
          resource_shape: @routes.oslc_qm_resource_shape_url("test-result"),
          resource_type: "http://open-services.net/ns/qm#TestResultQuery"
        }
      end

      define_creation_factory do
        {
          title: "Creating Test Case (OSLC QM)",
          label: "Creation Factory for Test Case",
          creation: @routes.oslc_qm_service_provider_test_cases_url(@project),
          resource_shape: @routes.oslc_qm_resource_shape_url("test-case"),
          resource_type: "http://open-services.net/ns/qm#TestCase"
        }
      end

      def after_initialize
        @resource_url = @routes.oslc_qm_service_provider_url(@project)
        @publisher_title = "QM Provider - #{@project.id}: #{@project.name}"
        @publisher_identifier = @routes.oslc_qm_service_providers_url
        @service_domain = "http://open-services.net/ns/qm#"
      end

      def to_atom
        ::Tmt::XML::Atom.new(xmlns: xmlns) do |atom|
          atom.add("id") { @controller.oslc_qm_service_provider_url(@project) }
          atom.add("title") { @project.name }
          atom.add("author") do |atom|
            atom.add("name") { @project.creator_name }
          end

          atom.add("updated") { @project.updated_at.iso8601 }
          atom.add("entry") do |atom|
            atom.add("id") { @controller.oslc_qm_service_provider_url(@project) }
            atom.add("title") { @project.name }
            atom.add("author") do |atom|
              atom.add("name") { @project.creator.name }
            end
            atom.add("content", type: "application/rdf+xml") do |atom|
              atom.add('rdf:RDF') do |atom|
                content(atom)
              end
            end
          end
        end.to_xml
      end

      private

      def selection_dialogues(handle)
        handle.add('oslc:selectionDialog') do |xml|
          xml.add('oslc:Dialog') do |xml|
            xml.add('dcterms:title') { 'OSCL QM Resource Selector' }
            xml.add('dcterms:label') { 'QM Test Plan' }
            xml.add('oslc:dialog', rdf: {resource: @routes.selection_dialog_oslc_qm_service_provider_test_plans_url(@project) })
            xml.add('oslc:hintWidth') { '400px' }
            xml.add('oslc:hintHeight') { '500px' }
            xml.add('oslc:resourceType', rdf: {resource: "http://open-services.net/ns/qm#resource" })
            xml.add('oslc:usage') { 'http://open-services.net/ns/core#default' }
          end
        end

        handle.add('oslc:selectionDialog') do |xml|
          xml.add('oslc:Dialog') do |xml|
            xml.add('dcterms:title') { 'OSCL QM Resource Selector' }
            xml.add('dcterms:label') { 'QM Test Case' }
            xml.add('oslc:dialog', rdf: {resource: @routes.selection_dialog_oslc_qm_service_provider_test_cases_url(@project) })
            xml.add('oslc:hintWidth') { '400px' }
            xml.add('oslc:hintHeight') { '500px' }
            xml.add('oslc:resourceType', rdf: {resource: "http://open-services.net/ns/qm#resource" })
            xml.add('oslc:usage') { 'http://open-services.net/ns/core#default' }
          end
        end

        handle.add('oslc:selectionDialog') do |xml|
          xml.add('oslc:Dialog') do |xml|
            xml.add('dcterms:title') { 'OSCL QM Resource Selector' }
            xml.add('dcterms:label') { 'QM Test Script' }
            xml.add('oslc:dialog', rdf: {resource: @routes.selection_dialog_oslc_qm_service_provider_test_scripts_url(@project) })
            xml.add('oslc:hintWidth') { '400px' }
            xml.add('oslc:hintHeight') { '500px' }
            xml.add('oslc:resourceType', rdf: {resource: "http://open-services.net/ns/qm#resource" })
            xml.add('oslc:usage') { 'http://open-services.net/ns/core#default' }
          end
        end
      end

    end
  end
end
