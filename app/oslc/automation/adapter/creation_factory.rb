# A Creation Factory
#
# Example:
#   https://jazz.net/wiki/bin/view/Main/RqmOslcQmV2Api
#   https://phkrief.wordpress.com/tag/oslc/

# Sending POST request to server it:
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
  module Automation
    module Adapter
      class CreationFactory < Oslc::Core::CreationFactory
        attr_reader :adapter

        private

        def after_initialize
          @type = 'http://jazz.net/ns/auto/rqm#AutomationAdapter'
          check_type
          @user_id = @options[:machine_id]
          @project = @options[:project]
          @object = Tmt::AutomationAdapter.new
          prepare_resource
        end

        def prepare_resource
          params = parse
          @object.user_id = @user_id
          @object.project = @project
          @object.name = params[:title]
          @object.description = params[:description]
          @object.adapter_type = params[:adapter_type]
          @object.polling_interval = params[:polling_interval]
        end

        # selecting options from XML content
        # Return: hash with options
        def parse
          result = {}
          doc = Nokogiri::XML.parse(@xml_content)
          result[:description] = doc.xpath("//dcterms:description").text
          result[:polling_interval] = read_text('//rqm_auto:pollingInterval')
          result[:title] = read_text("//dcterms:title")
          result[:adapter_type] = doc.xpath("//dcterms:type").text
          result
        end
      end
    end
  end
end
