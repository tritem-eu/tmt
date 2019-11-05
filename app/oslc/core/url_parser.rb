module Oslc
  module Core
    class UrlParser

      def initialize(options={})
        @routes = ::Oslc::Core::Routes.get_singleton
      end

      def download_qm_service_provider_test_script_id_for(url)
        url_pattern = @routes.download_oslc_qm_service_provider_test_script_url('*', '*')
        select_ids_from(url, url_pattern)[1]
      end

      def qm_service_provider_id_for(url)
        url_pattern = @routes.oslc_qm_service_provider_url('*')
        select_ids_from(url, url_pattern)[0]
      end

      def qm_instance_shape_id_for(url)
        url_pattern = @routes.oslc_qm_resource_shape_url('*')
        select_ids_from(url, url_pattern)[0]
      end

      def test_plan_id_for(url)
        url_pattern = @routes.oslc_qm_service_provider_test_plan_url('*', '*')
        select_ids_from(url, url_pattern)[1]
      end

      def test_execution_record_id_for(url)
        url_pattern = @routes.oslc_qm_service_provider_test_execution_record_url('*', '*')
        select_ids_from(url, url_pattern)[1]
      end

      def automation_instance_shape_id_for(url)
        url_pattern = @routes.oslc_automation_resource_shape_url('*')
        select_ids_from(url, url_pattern)[0]
      end

      def automation_plan_id_for(url)
        url_pattern = @routes.oslc_automation_service_provider_plan_url('*', '*')
        select_ids_from(url, url_pattern)[1]
      end

      def automation_adapter_id_for(url)
        url_pattern = @routes.oslc_automation_service_provider_adapter_url('*', '*')
        select_ids_from(url, url_pattern)[1]
      end

      def automation_request_id_for(url)
        url_pattern = @routes.oslc_automation_service_provider_request_url('*', '*')
        select_ids_from(url, url_pattern)[1]
      end

      def test_case_id_for(url)
        url_pattern = @routes.oslc_qm_service_provider_test_case_url('*', '*')
        select_ids_from(url, url_pattern)[1]
      end

      def test_script_id_for(url)
        url_pattern = @routes.oslc_qm_service_provider_test_script_url('*', '*')
        select_ids_from(url, url_pattern)[1]
      end

      def automation_service_provider_id_for(url)
        url_pattern = @routes.oslc_automation_service_provider_url('*')
        select_ids_from(url, url_pattern)[0]
      end

      def user_id_for(url)
        url_pattern = @routes.oslc_user_url('*')
        select_ids_from(url, url_pattern)[0]
      end

      private

      def select_ids_from(url, url_pattern)
        url = url.gsub(/^<|>$/, '').gsub(/^"|"$/, '')
        get_ids_from_url(url, url_pattern)
      end

      def get_ids_from_url(url, pattern)
        elements = pattern.split('*')
        result = url
        elements.each do |sub_url|
          result = result.sub(sub_url, '*')
        end
        result.split('*').delete_if{ |item| item == ''}
      end

    end
  end
end
