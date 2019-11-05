# Specification:
#   http://open-services.net/bin/view/Main/QmSpecificationV2#Resource_TestScript
# Example:
#   http://open-services.net/bin/view/Main/QmSpecificationV2Samples#TestScript_RDF_XML
module Oslc
  module Qm
    module TestScript
      class Resource < Oslc::Core::Resource

        def after_initialize
          @test_case = @object.test_case
          @project = @test_case.project

          @resource_type = 'oslc_qm:TestScript'
          @object_url = @routes.oslc_qm_service_provider_test_script_url(@project, @object)
        end

        define_namespaces do
          {
            dcterms: :dcterms,
            rdf: :rdf,
            oslc_qm: :oslc_qm,
            oslc: :oslc
          }
        end

        define_property 'dcterms:title' do
          string_to_define @object.comment
        end

        define_property 'dcterms:description' do
          string_to_define "#{@object.comment}"
        end

        define_property 'dcterms:identifier' do
          string_to_define @routes.oslc_qm_service_provider_test_script_url(@project, @object)
        end

        define_property 'dcterms:creator' do
          url_to_define @routes.oslc_user_url(@object.author)
        end

        define_property 'dcterms:created' do
          date_to_define @object.created_at
        end

        define_property 'dcterms:modified' do
          date_to_define @object.updated_at
        end

        define_property 'oslc:instanceShape' do
          url_to_define @routes.oslc_qm_resource_shape_url("test-script")
        end

        define_property 'oslc:serviceProvider' do
          url_to_define @routes.oslc_qm_service_provider_url(@project)
        end

        define_property 'oslc_qm:executionInstructions' do
          url_to_define @routes.download_oslc_qm_service_provider_test_script_url(@project, @object)
        end

        define_property 'dcterms:contributor' do
          @project.users.map do |user|
            url_to_define @routes.oslc_user_url(user)
          end
        end

      end
    end
  end
end
