module Oslc
  module User
    class Resource < ::Oslc::Core::Resource
      define_namespaces do
        {
          foaf: :foaf,
          rdf: :rdf
        }
      end

      def after_initialize
        define_resource_type 'foaf:Person'

        define_object_url do
          @routes.oslc_user_url(@object)
        end
      end

      define_property 'foaf:mbox' do
        url_to_define "mailto:#{@object.email}"
      end

      define_property 'foaf:name' do
        string_to_define @object.name.to_s
      end
    end
  end
end
