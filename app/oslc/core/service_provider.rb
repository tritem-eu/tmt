# A Service Provider describes a set of services offered by an OSLC implementation.
#
# Description:
#   http://open-services.net/bin/view/Main/OslcCoreSpecification?sortcol=table;table=up#Service_Provider_Resources
# Example:
#   http://open-services.net/bin/view/Main/AMServiceDescriptionV1
#   http://open-services.net/bin/view/Main/CmSpecificationV2Samples#Service_Provider_Samples
module Oslc
  module Core
    class ServiceProvider

      @@query_capabilities = {}
      @@creation_factories = {}

      def initialize(project)
        @routes = ::Oslc::Core::Routes.get_singleton
        @project = project
        after_initialize
      end

      def after_initialize

      end

      def self.define_query_capability(&options)
        @@query_capabilities[self] ||= []
        @@query_capabilities[self] << options
      end

      def self.define_creation_factory(&options)
        @@creation_factories[self] ||= []
        @@creation_factories[self] << options
      end

      def to_xml
        ::Tmt::XML::RDFXML.new(xmlns: xmlns, xml: {lang: :en}) do |xml|
          content(xml)
        end.to_xml
      end

      private

      def content(handle)
        handle.add("oslc:ServiceProvider", rdf: {about: @resource_url}) do |xml|
          # Title of the service provider
          xml.add("dcterms:title", rdf: {parseType: "Literal"}) { @project.name }

          # Description of the service provider
          xml.add("dcterms:description", rdf: {parseType: "Literal"}) { @project.description }

          # Describes the software product that provides the implementation.
          xml.add("dcterms:publisher") do |xml|
            xml.add("oslc:Publisher") do |xml|
              xml.add("dcterms:title"){ @publisher_title }
              xml.add("oslc:label") { ApplicationHelper.version }
              xml.add("dcterms:identifier") { @publisher_identifier }
              xml.add("oslc:icon", rdf: {resource: "#{@routes.root_url}assets/favicon.ico"})
            end
          end

          # Describes a service offered by the service provider.
          xml.add("oslc:service") do |xml|
            xml.add("oslc:Service") do |xml|
              xml.add("oslc:domain", rdf: { resource: @service_domain })
              query_capabilities(xml)
              creation_factories(xml)
              selection_dialogues(xml)
            end
          end

          # A URL that may be used to retrieve a web page to determine additional details about the service provider.
          xml.add("oslc:details", rdf: {resource: @routes.project_url(@project)})
          prefix_definition(xml)
        end
      end

      def selection_dialogues(handle)

      end

      def query_capabilities(handle)
        @@query_capabilities[self.class].each do |option|
          query_capability(handle, self.instance_exec(&option))
        end
      end

      def creation_factories(handle)
        @@creation_factories[self.class].each do |option|
          creation_factory(handle, self.instance_exec(&option))
        end
      end

      def creation_factory(handle, options={})
        handle.add("oslc:creationFactory") do |xml|
          xml.add("oslc:CreationFactory") do |xml|
            xml.add("dcterms:title") { options[:title] }
            xml.add("oslc:label") { options[:label] } if options[:label]
            xml.add("oslc:creation", rdf: {resource: options[:creation]}) if options[:creation]
            xml.add("oslc:resourceShape", rdf: {resource: options[:resource_shape]}) if options[:resource_shape]
            xml.add("oslc:resourceType", rdf: {resource: options[:resource_type] }) if options[:resource_type]
          end
        end
      end

      # handle: Oslc::Klass or Tmt::Oslc::Property object
      # options: it is hash consist of keys (title, label, query_base, resource_type, resource_shape)
      def query_capability(handle, options={})
        handle.add("oslc:queryCapability") do |xml|
          xml.add("oslc:QueryCapability") do |xml|
            xml.add("dcterms:title") { options[:title] }
            xml.add("oslc:label") { options[:label] }
            xml.add("oslc:queryBase", rdf: {resource: options[:query_base]})
            xml.add("oslc:resourceShape", rdf: {resource: options[:resource_shape]})
            xml.add("oslc:resourceType", rdf: {resource: options[:resource_type]})
            xml.add("oslc:usage", rdf: {resource: "http://open-services.net/ns/core#default"})
          end
        end
      end

      # Defines a namespace prefix for use in JSON representations and in forming OSLC Query Syntax strings.
      def prefix_definition(handler)
        [
          :rdf,
          :rdfs,
          :oslc,
          :oslc_qm,
          :oslc_auto,
          :oslc_cm,
          :oslc_rm,
          :dcterms,
          :owl,
          :xmls,
          :foaf,
          :foaf,
          :jfs,
          :rqm_auto,
          :rqm_qm
        ].each do |key|
          key = key.to_s
          url = Tmt::XML::Base.vocabulary_type_url(key)
          handler.add("oslc:prefixDefinition") do |xml|
            xml.add("oslc:PrefixDefinition") do |xml|
              xml.add("oslc:prefix") { key }
              xml.add("oslc:prefixBase") { url }
            end
          end
        end
      end

      def xmlns
        {
          dcterms: :dcterms,
          rdf: :rdf,
          oslc_qm: :oslc_qm,
          rdfs: "http://w3.org/2000/01/rdf-schema#",
          oslc: :oslc
        }
      end

    end
  end
end
