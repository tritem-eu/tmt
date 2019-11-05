module Oslc
  module Qm
    module TestPlan
      class Resource < ::Oslc::Core::Resource

        def after_initialize
          if @cache
            @provider = @cache.project
            @test_cases = @cache.test_cases_for(@object)
          else
            @cache = ::Oslc::Qm::TestPlan::Cache.new([@object])
            @test_cases = @cache.test_cases_for(@object)
            @provider = @object.project
          end
          @resource_type = 'oslc_qm:TestPlan'
          @object_url = @routes.oslc_qm_service_provider_test_plan_url @provider, @object
        end

        define_namespaces do
          {
            dcterms: :dcterms,
            rdf: :rdf,
            oslc_qm: :oslc_qm,
            oslc: :oslc
          }
        end

        define_property 'dcterms:contributor' do
          @provider.users.map do |user|
            url_to_define @routes.oslc_user_url(user)
          end
        end

        define_property 'dcterms:created' do
          date_to_define @object.created_at
        end

        define_property 'dcterms:creator' do
          url_to_define @routes.oslc_user_url(@object.creator_id)
        end

        define_property 'dcterms:description' do
          string_to_define @object.description
        end

        define_property 'dcterms:identifier' do
          string_to_define @routes.oslc_qm_service_provider_test_plan_url(@provider, @object)
        end

        define_property 'dcterms:modified' do
          date_to_define @object.updated_at
        end

        define_property 'dcterms:title' do
          string_to_define @object.name
        end

        define_property 'oslc:instanceShape' do
          url_to_define @routes.oslc_qm_resource_shape_url("test-plan")
        end

        define_property 'oslc:serviceProvider' do
          url_to_define @routes.oslc_qm_service_provider_url(@provider)
        end

        define_property 'oslc_qm:usesTestCase' do
          @test_cases.map do |test_case|
            url_to_define @routes.oslc_qm_service_provider_test_case_url(@provider, test_case)
          end
        end
      end
    end
  end
end
