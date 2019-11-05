require_relative 'resource_shape_property'

module Oslc
  module Core
    # This class is only to inherit by other class.
    # We can generate ResourceShape content
    # (using this specification: http://open-services.net/bin/view/Main/OSLCCoreSpecAppendixA#oslc_ResourceShape_Resource)
    # by this class.
    #
    # Documentation:
    #   http://open-services.net/pub/Main/QmSpecV2Issues/QM_Resource_Shapes.txt#
    #
    # For example:
    # Defining class:
    #   class DummyResourceShape < Oslc::Core::ResourceShape
    #     after_initialize do
    #
    #       request_uri do
    #         @controller.root_url
    #       end

    #       title_of_shape "QM V2 Automation Resource"

    #       resource_type 'http://jazz.net/ns/auto/rqm#AutomationRequest'

    #       namespaces do
    #         {
    #           dcterms: :dcterms,
    #           rdf: :rdf,
    #           oslc: :oslc,
    #           oslc_qm: :oslc_qm,
    #           rqm_auto: :rqm_auto,
    #           oslc_auto: :oslc_auto
    #         }
    #       end

    #       [
    #         [:title,                    "oslc:Exactly-one",  "true",     "rdf:XMLLiteral",  nil,               nil,                           "dcterms:title",                     "Title",                       nil,                           "false", "false",              "Title (reference: Dublin Core) of the resource represented as rich text in XHTML content. SHOULD include only content that is valid inside an XHTML &lt;span&gt; element."],
    #         [:instanceShape,            "oslc:Zero-or-one",  "true",     "oslc:Resource",   'oslc:Reference',  'oslc:ResourceShape',          "oslc:instanceShape",                "Instance Shape",              nil,                           "true",  "false",              "Resource Shape that provides hints as to resource property value-types and allowed values."],
    #         [:type,                     "oslc:Zero-or-many", "true",     "oslc:Resource",   'oslc:Reference',  'oslc_qm:TestPlan',            "rdf:type",                          "Type",                        nil,                           "true",  "false",              "The resource type URIs." ],
    #         [:modified,                 "oslc:Zero-or-one",  "true",     "rdfs:dateTime",   nil,               nil,                           "dcterms:modified",                  "Modified",                    nil,                           "false", "false",              "Timestamp of latest resource modification (reference: Dublin Core)."],
    #         [:serviceProvider,          "oslc:Zero-or-many", "true",     "oslc:Resource",   'oslc:Reference', 'oslc:ServiceProvider',         "oslc:serviceProvider",              "Service Provider",            nil,                           "true",  "false",              "The scope of a resource is a link to the resource's OSLC Service Provider."],
    #       ].each do |name, occurs, read_only, value_type, representation, range, property_definition, title, value_shape, hidden, is_member_property, description|
    #         add_property(property_definition) do |h|
    #           h.description description
    #           h.occurs occurs
    #           h.hidden hidden
    #           h.is_member_property is_member_property
    #           h.name name
    #           h.read_only read_only
    #           h.value_type value_type
    #           h.representation representation
    #           h.range range
    #           h.title title
    #           h.value_shape value_shape
    #         end
    #       end
    #     end
    #   end
    #
    # The use of DummyResourceShape class
    #   resource_shape = DummyResourceShape.new(controller_instance)
    # Parsing to XML format
    #    resource_shape.to_xml
    #  Parsing to RDF format
    #    resource_shape.to_rdf
    class ResourceShape

      @@namespaces = {}
      @@properties = {}

      def self.define_namespaces &block
        @@namespaces[self] = self.instance_eval(&block)
      end

      def self.define_properties &block
        @@properties[self] = block
      end

      def self.after_initialize &block
        define_method(:after_initialize) do
          self.instance_eval(&block)
        end
      end

      def initialize
        @properties = {}
        @routes = ::Oslc::Core::Routes.get_singleton
        after_initialize
        [
          :request_uri,
          :title_of_shape,
          :resource_type
        ].each do |name|
          unless instance_variable_defined?("@#{name}")
            raise StandardError, "#{self.class.name} has not defined '@#{name}' variable or '#{name}' method was not invoked."
          end
        end
        @namespaces = @@namespaces[self.class]
        load_properties
      end

      # parse data into RDF format
      def to_rdf
        Tmt::XML::RDFXML.new(xmlns: @namespaces, xml: {lang: :en}) do |xml|
          body(xml)
        end.to_rdf
      end

      # parse data into XML format
      def to_xml
        Tmt::XML::RDFXML.new(xmlns: @namespaces, xml: {lang: :en}) do |xml|
          body(xml)
        end.to_xml
      end

      private

      def load_properties
        table = self.instance_exec(&@@properties[self.class])
        header = table.shift
        table.each do |item|
          property = Oslc::Core::ResourceShapeProperty.new

          header.each_with_index do |method_name, position|
            value = item[position]
            property.method(method_name).call(value)
          end
          values = property.values
          property_definition = values.delete(:property_definition)
          @properties[property_definition] = values
        end
      end

      def body(handle)
        handle.add("oslc:ResourceShape", rdf: {about: @request_uri}) do |xml|
          xml.add("dcterms:title", rdf: {dataType: "http://www.w3.org/2001/XMLSchema#string"}) { @title_of_shape}
          xml.add('oslc:describes', rdf: {resource: @resource_type})
          @properties.each do |property_name, params|
            xml.add("oslc:property") do |xml|
              xml.add("oslc:Property") do |xml|
                xml.add("oslc:propertyDefinition", rdf: {resource: xml.vocabulary_type_url(property_name)})
                content(xml, params)
              end
            end
          end
        end
      end

      # oslc:hidden - A hint that indicates that property MAY be hidden when presented in a user interface.
      #   link: http://open-services.net/wiki/core/CoreVocabulary/#hidden
      # oslc:isMemberProperty - Used to define when a property is a member of a container, useful for query.
      #   link: http://open-services.net/wiki/core/CoreVocabulary/#isMemberProperty
      # oslc:name - Name of property being defined, i.e. second part of property's Prefixed Name.
      # oslc:occurs - MUST be either http://open-services.net/ns/core#Exactly-one, http://open-services.net/ns/core#Zero-or-one, http://open-services.net/ns/core#Zero-or-many or http://open-services.net/ns/core#One-or-many.
      # oslc:readOnly - true if the property is read-only. If omitted, or set to false, then the property is writable. Providers SHOULD declare a property read-only when changes to the value of that property will not be accepted after the resource has been created, e.g. on PUT/PATCH requests. Consumers should note that the converse does not apply: Providers MAY reject a change to the value of a writable property.
      # oslc:valueType - A URI that indicates the value type, for example XML Schema or RDF URIs for literal value types, and OSLC-specified for others. If this property is omitted, then the value type is unconstrained.
      # oslc:representation - Should be http://open-services.net/ns/core#Reference, http://open-services.net/ns/core#Inline or http://open-services.net/ns/core#Either
      # oslc:range - For properties with a resource value-type, Providers MAY also specify the range of possible resource types allowed, each specified by URI. The default range is http://open-services.net/ns/core#Any.
      # oslc:description - All vocabulary URIs defined in the OSLC Core namespace.
      # oslc:propertyDefinition - URI of the property whose usage is being described.
      # oslc:valueShape - if the value-type is a resource type, then Property MAY provide a shape value to indicate the Resource Shape that applies to the resource.
      def content(xml, params)
        xml.add("oslc:name", rdf: {datatype: xml.vocabulary_type_url('xmls:string')}) {params[:name]}
        xml.add("oslc:occurs", rdf: {resource: xml.vocabulary_type_url(params[:occurs]) })
        xml.add("oslc:readOnly", rdf: {datatype: xml.vocabulary_type_url('xmls:boolean')}) { params[:read_only] }
        xml.add("oslc:valueType", rdf: {resource: xml.vocabulary_type_url(params[:value_type])})
        xml.add("oslc:representation", rdf: {resource: xml.vocabulary_type_url(params[:representation])}) if params[:representation]
        xml.add("oslc:range", rdf: {resource: xml.vocabulary_type_url(params[:range])}) if params[:range]
        xml.add("dcterms:description", rdf: {datatyp: xml.vocabulary_type_url('xmls:string')}) { params[:description]}
        xml.add("dcterms:title", rdf: {datatype: xml.vocabulary_type_url('xmls:string')}) { params[:title] }
        xml.add("oslc:valueShape", rdf: {resource: params[:value_shape_url]}) if params[:value_shape_url]
        xml.add("oslc:hidden", rdf: {datatype: xml.vocabulary_type_url('xmls:boolean')}) { params[:hidden] }
        xml.add("oslc:isMemberProperty", rdf: {datatype: xml.vocabulary_type_url('xmls:boolean')}) { params[:is_member_property] || 'false' }
      end

      # URI of HTTP request
      def request_uri(&block)
        @request_uri = block.call
      end

      # Title of InstanceShape
      def title_of_shape(value)
        @title_of_shape = value
      end

      # OSLC type of InstanceShape
      def resource_type(value)
        @resource_type = value
      end

    end
  end
end
