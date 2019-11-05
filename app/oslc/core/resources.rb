# Documentation:
#   http://open-services.net/bin/view/Main/OSLCCoreSpecQuery
# Examples:
#   http://open-services.net/bin/view/Main/OslcSimpleQuerySyntaxV1
#   http://open-services.net/bin/view/Main/OslcSimpleQuerySemanticsV1
#   http://dev.eclipse.org/mhonarc/lists/lyo-dev/msg00390.html
#   http://pic.dhe.ibm.com/infocenter/tivihelp/v3r1/index.jsp?topic=%2Fcom.ibm.psc.doc_1.1.0.1%2Frs_original%2Ftshoot%2Frs_c_ts_useful_registry_srvc_query.html
#   https://jazz.net/library/content/articles/rtc/3.0/oslc-workshop/rsc/2011-08-19-OSLC-CM-workshop.pdf
#
# http://www-01.ibm.com/support/knowledgecenter/SSSHYH_7.1.0/com.ibm.netcoolimpact.doc_7.1/solution/oslc_query_syntax_c.html
#   * oslc.properties query parameter
#       Use the oslc.properties query parameter to display the properties for an individual resource URI that does not contain any rdfs:member lists
#   * oslc.select query parameter
#       If the identifiers that you want to limit the properties of belong to a member list for a resource, use the oslc.select query parameter.
#
# getting started:
#   Example:
#     model name:
#       DummyModel
#     resource class:
#       class Oslc::DummyModel < Oslc::Core::Resource
#         add_selector 'rdf:type', :rdf_resource do
#           [{rdf: {resource: "http://localhost:3000"}}]
#         end
#         add_selector 'dcterms:identifier', :int do
#           [{}, 23]
#         end
#
#         def self.namespaces
#           {
#             rdf: :rdf,
#             dcterms: :identifier
#           }
#         end
#       end
#     query syntax class:
#       class Oslc::DummyModel::QuerySyntax < Oslc::Core::QuerySyntax
#          def initialize(options={})
#            @all_entries = @class_name.all
#            @resource_class = ::Oslc::DummyModel
#            @selector_for_entry = "oslc_auto:automationAdapter"
#          end
#
#         def namespaces
#           ::Oslc::DummyModel.namespaces.merge({
#             rdfs: :rdfs
#           })
#         end
#
#       end

module Oslc
  module Core
    class Resources
      include Rails.application.routes.url_helpers

      attr_reader :resource_type, :entry_type

      def after_initialize
        # The method can be implemented by the inherited class
      end

      def define_resource_type(uri)
        @resource_type = uri
      end

      def define_entry_type(uri)
        @entry_type = uri
      end

      def define_resource_class(klass)
        @resource_class = klass
      end

      def initialize(options={})
        @provider = options[:provider]
        @routes = ::Oslc::Core::Routes.get_singleton
        @oslc_select = options[:oslc_select]
        @oslc_where = options[:oslc_where]
        @all_entries = nil
        after_initialize
      end

      # Return list all active entries which match to 'oslc.where' query
      #
      # To use this method we should define the methods:
      #   namespaces - hash with namespaces for XML format
      # moreover in initializer we should define instance variables:
      #   all_entries - array of entries from model to analize
      #   resource_class - class which inherits ::Oslc::Core::Resource class
      #   selector_for_entry - selector which will show for one entry in XML format
      #
      # Givfe me the bugs with identifier 4242
      #   http://example.com/bugs?oslc.where=dcterms:identifier="4242“
      # Give me the bugs with "high priority" created after April 2010
      #   http://example.com/bugs?oslc.where=cm:severity="high" and dcterms:created>"2010-04-01“
      # Give me the bugs created by "Jhon Smith"
      #   http://example.com/bugs?oslc.where=dcterms:creator{foaf:givenName="John" and foaf:familyName="Smith"}
      def to_rdf
        rdfxml.to_rdf
      end

      def to_xml
        rdfxml.to_xml
      end

      private

      def rdfxml
        Tmt::XML::RDFXML.new(xmlns: namespaces,
        xml: {lang: :en}) do |xml|
          xml.add(@resource_type, rdf: {about: @url}) do |xml|
            @all_entries.each do |entry|
              xml.add(@entry_type) do |xml|
                @resource_class.new(entry, {
                  oslc_properties: @oslc_select,
                  project: @provider,
                  cache: @cache
                }).body(xml)
              end
            end
          end
        end
      end

    end
  end
end
