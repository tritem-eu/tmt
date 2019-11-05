
module Oslc
  module Core
    # It is main class for all OSLC of resource classes
    # Example:
    #   model name:
    #     DummyModel
    #   resource class:
    #     class Oslc::DummyModel < Oslc::Core::Resource
    #       def after_initialize
    #         @test_case = @object.test_case
    #         @resource_type = 'oslc_auto:AutomationRequest'
    #         @object_url = @routes.root_url
    #       end
    #
    #       define_selector 'rdf:type' do
    #         url_to_define "http://localhost:3000"
    #       end
    #
    #       define_property 'dcterms:identifier' do
    #         long_to_define(23)
    #       end
    #
    #       define_property "oslc_auto:inputParameter" do
    #         @test_case.custom_field_values.map do |custom_field|
    #           define_sub_selector({}, "oslc_auto:ParameterInstance") do |handler|
    #             define_sub_selector(handler, "rdf:value") do |handler|
    #               string_to_define custom_field.value
    #             end
    #           end
    #         end
    #       end
    #
    #       define_namespaces
    #         {
    #           rdf: :rdf,
    #           dcterms: :identifier,
    #           oslc_qm: :oslc_qm
    #         }
    #       end
    #     end
    class Resource
      attr_reader :resource_type

      @@properties = {}

      def define_sub_selector(parent, selector, &handler)
        parent[selector] ||= []
        hash = {}
        array = handler.call(hash)
        if not array.nil? and hash.empty?
          parent[selector] << handler.call(hash)
        else
          parent[selector] << {
            attributes: {},
            content: hash
          }
        end
        content_to_define(parent)
      end

      def self.define_property name, &options
        method_name = 'property_' + name.gsub(':', '_').underscore
        self.send(:define_method, method_name, &options)
        @@properties[self] ||= {}
        @@properties[self][name] ||= []
        @@properties[self][name] << method_name
      end

      def add_selector selector, options
        @selectors[selector] ||= []
        @selectors[selector] << options
      end

      def after_initialize

      end

      def self.define_namespaces(&handler)
        define_singleton_method("namespaces") do
          handler.call
        end
      end

      def define_object_url(&handler)
        @object_url = handler.call
      end

      def define_resource_type(selector)
        @resource_type = selector
      end

      def initialize(object, options={})
        @@properties[self.class] ||= {}
        @options = options
        @selectors = {}
        @object = object
        @cache = options[:cache]
        @project = options[:project]
        @routes = ::Oslc::Core::Routes.get_singleton
        @oslc_properties = parse_oslc_properties(options[:oslc_properties])
        after_initialize

        if @object_url.nil?
          raise "@object_url variable isn't defined!"
        end
        if @resource_type.nil?
          raise "@resourcetype variable isn't defined!"
        end
        load_selectors
       end


      # namespaces of RDF/XML format
      # this method must be completed in child class
      # For example:
      #   {
      #     dctersm: :dcterms,
      #     rdf: :rdf
      #   }
      def self.namespaces
        {
          rdf: :rdf
        }
      end

      def to_rdf
        Tmt::XML::RDFXML.new(xmlns: self.class.namespaces) do |rdf|
          body(rdf)
        end.to_rdf
      end

      def to_xml
        Tmt::XML::RDFXML.new(xmlns: self.class.namespaces) do |xml|
          body(xml)
        end.to_xml
      end

      def body(xml)
        xml.add(@resource_type, rdf: {about: @object_url }) do |xml|
          content_for_xml(xml)
        end
      end

      # xml - instance of Tmt::XML::Base class
      def content_for_xml(xml, selectors=@selectors, options={})
        selectors.each do |selector, array|
          array.each do |params|
            selector_data = params
            unless options[:active_oslc_properties] == true or @oslc_properties.nil? or @oslc_properties.has_key?(selector)
              next
            end
            unless defined_selector?(selector_data)
              next
            end
            if params[:content].nil?
              xml.add(selector, params[:attributes])
            else
              unless params[:content].class == Hash
                xml.add(selector, params[:attributes]) { params[:content].to_s }
              else
                xml.add(selector, params[:attributes]) do |xml|
                  content_for_xml(xml, params[:content], {active_oslc_properties: true})
                end
              end
            end
          end
        end
      end

      # input:
      #   xml - handle of Tmt::XML::Property object
      #   entry - entry of record to show
      # output:
      #   information about entry in XML (using @oslc_select params)
      def parse_oslc_properties(string)
        result = nil
        string = string.to_s
        if ['*', ''].include?(string)
          result = nil
        elsif string =~ /^\{\}$/
          ## TODO
        else
          result = {}
          string.to_s.split(",").each do |selector|
            result[selector] = nil
          end
        end
        result
      end

      private

      def load_selectors
        @@properties[self.class].each do |key, method_names|
          method_names.each do |method_name|
            options = self.method(method_name).call
            if options.class == Hash
              options = [options]
            end
            options.each do |option|
              add_selector(key, option)
            end
          end
        end
      end

      def defined_selector?(data)
        not (data[:content].blank? and [{}, nil, ''].include?(data[:attributes]))
      end

      def date_to_define(date)
        return nothing_to_define if date.nil?
        value = date.utc.iso8601(6)
        {
          attributes: {rdf: {datatime: "http://www.w3.org/2001/XMLSchema#dateTime"}},
          content: value
        }
      end

      def string_to_define(string)
        return nothing_to_define if string.nil?

        {
          attributes: {rdf: {datatype: "http://www.w3.org/2001/XMLSchema#string"}},
          content: string
        }
      end

      def long_to_define(number)
        return nothing_to_define if number.nil?
        {
          attributes: {rdf: {datatype: "http://www.w3.org/2001/XMLSchema#long"}},
          content: number
        }
      end

      def content_to_define(content)
        {
          attributes: {},
          content: content
        }
      end

      def boolean_to_define(boolean)
        return nothing_to_define unless['false', 'true'].include?(boolean.to_s)
        {
          attributes: {rdf: {datatype: "http://www.w3.org/2001/XMLSchema#boolean"}},
          content: boolean.to_s
        }
      end

      def url_to_define(url)
        return nothing_to_define if url.nil?
        {
          attributes: {rdf: {resource: url}}
        }
      end

      def nothing_to_define
        {
          attributes: {}
        }
      end

    end
  end
end
