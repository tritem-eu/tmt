require_relative 'core/routes'

module Oslc
  class Rootservices
    def initialize
      @routes = ::Oslc::Core::Routes.get_singleton
    end

    def to_rdfxml
      Tmt::XML::RDFXML.new(xmlns: {
        rdf: :rdf,
        oslc_qm: 'http://open-services.net/xmlns/qm/1.0/',
        oslc_auto: :oslc_auto
      }) do |xml|
        xml.add("rdf:Description", rdf: {about: @routes.rootservices_url()}) do |xml|
          xml.add("oslc_qm:qmServiceProviders", rdf: {resource: @routes.oslc_qm_service_providers_url})
          xml.add("oslc_auto:autoServiceProviders", rdf: {resource: @routes.oslc_automation_service_providers_url})
        end
      end.to_xml
    end
  end
end
