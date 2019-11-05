# A Creation Factory
#
# Example:
#   https://jazz.net/wiki/bin/view/Main/RqmOslcQmV2Api
#   https://phkrief.wordpress.com/tag/oslc/

# Send POST request to server it:
# <?xml version="1.0" encoding="UTF-8"?>\n'
# <rdf:RDF xmlns:rqm_qm="http://jazz.net/ns/qm/rqm#"'
#          xmlns:dcterms="http://purl.org/dc/terms/"'
#          xmlns:oslc="http://open-services.net/ns/core#"'
#          xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"'
#          xmlns:rqm_auto="http://jazz.net/ns/auto/rqm#"'
# >
#   <rdf:Description>
#      <rdf:type rdf:resource="http://open-services.net/ns/qm#TestCase"/>
#      <dcterms:title>Test Test Adapter</dcterms:title>
#      <dcterms:description>Test Test Adapter Description</dcterms:description>
#   </rdf:Description>
# </rdf:RDF>

module Oslc
  module Core
    class CreationFactory
      def initialize(xml_content, options={})
        @error_message = nil
        @xml_content = xml_content
        @doc = Nokogiri::XML.parse(@xml_content)
        @options = options
        @object = nil
        @type = nil
        @object_saved = nil
        after_initialize
      rescue => e
        @error_message = e.message
      end

      def status_code
        if @error_message == nil and @object_saved == true
          return 201
        else
          400
        end
      end

      def save
        if @error_message == nil
          if @object.save
            @object_saved = true
            return true
          else
            @error_message = "An object of type #{@type} cannot be created. "
            @error_message += @object.errors.full_messages.join(', ')
            return false
          end
        end
        return false
      end

      def response
        if @error_message
          Oslc::Error.new(400, @error_message).to_rdfxml
        else
          if @object.errors.empty?
            Tmt::XML::RDFXML.new(xmlns: {
              dcterms: :dcterms,
              rdf: :rdf
            }, xml: {land: :en}) do |xml|
              xml.add("dcterms:identifier") { @object.id.to_s }
            end.to_xml
          else
            message = @object.errors.full_messages.join('. ')
            Oslc::Error.new(400, message).to_rdfxml
          end
        end
      end

      #doc must be instance of Nokogiri::XML
      def read_resource(selector)
        @doc.xpath(selector).first.attributes['resource'].value
      rescue
        raise StandardError, "'#{selector}' selector cannot be parsed"
      end

      def read_text(selector)
        @doc.xpath(selector).first.text
      rescue
        raise StandardError, "'#{selector}' selector cannot be parsed"
      end

      def check_type
        type = parse_type
        if type == nil
          raise StandardError, "Type of content is incorrect"
        end
        unless type == @type
          raise StandardError, "Type of content is not equal '#{@type}'"
        end
      end

      private

      def parse_type
        read_resource('//rdf:type')
      rescue
        nil
      end

    end
  end
end
