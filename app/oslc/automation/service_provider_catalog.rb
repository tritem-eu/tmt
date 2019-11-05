# http://open-services.net/bin/view/Main/AMServiceDescriptionV1
# Bugzilla http://open-services.net/resources/tutorials/integrating-products-with-oslc/integrating-with-an-oslc-provider/automated-bug-creation/
module Oslc
  module Automation
    class ServiceProviderCatalog
      include ActionView::Helpers::AssetTagHelper

      def initialize(projects)
        @projects = projects
        @routes = ::Oslc::Core::Routes.get_singleton
      end

      def to_rdfxml(options={})
        value = Tmt::XML::RDFXML.new(xmlns: {
          dcterms: :dcterms,
          foaf: :foaf,
          rdf: :rdf,
          oslc: :oslc
        }, xml: {lang: :en}) do |xml|
          xml.add("oslc:ServiceProviderCatalog", rdf: {about: @routes.oslc_automation_service_providers_url}) do |xml|
            xml.add("dcterms:title", rdf: {parseType: "Literal"}) { "TMT Automation Service Provider Catalog" }
            xml.add("dcterms:description", rdf: {parseType: "Literal"}) { "TMT Automation Service Provider Catalog." }
            xml.add("dcterms:publisher") do |xml|
              xml.add("oslc:Publisher") do |xml|
                xml.add("dcterms:title"){ "TMT Automation" }
                xml.add("oslc:label") { ApplicationHelper.version }
                xml.add("dcterms:identifier") { @routes.root_url }
                xml.add("oslc:icon", rdf: {resource: "#{@routes.root_url}assets/favicon.ico"})
              end
            end

            # Namespace URI of the specification that is implemented by this service. In most cases this namespace URI will be for an OSLC domain, but other URIs MAY be used.
            xml.add "oslc:domain", rdf: {resource: "http://open-services.net/ns/auto#"}

            # A service offered by the service provider.
            @projects.each do |project|
              xml.add("oslc:serviceProvider") do |xml|
                xml.add("oslc:ServiceProvider", rdf: {about: @routes.oslc_automation_service_provider_url(project)}) do |xml|
                  xml.add("dcterms:title") { project.name }
                  xml.add("dcterms:description") { project.description }
                  xml.add("oslc:details", rdf: {resource: @routes.project_url(project)})
                end
              end
            end

          end
        end.to_xml
      end
    end
  end
end
