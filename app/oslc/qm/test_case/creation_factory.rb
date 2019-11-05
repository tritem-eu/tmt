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
  module Qm
    module TestCase
      class CreationFactory

        attr_reader :test_case

        def initialize(xml_content, project, creator)
          @xml_content = xml_content
          @project = project
          @creator = creator
          @error_message = nil
          prepare_test_case
        end

        def prepare_test_case
          @test_case = Tmt::TestCase.new
          @test_case.type_id = Tmt::OslcCfg.cfg.test_case_type_id
          @test_case.project = @project
          @test_case.creator = @creator
          params = parse
          @test_case.description = params[:description]
          @test_case.name = params[:name]
        rescue => e
          @error_message = e.message
        end

        def save
          return false if @error_message == true
          @test_case.save
        end

        def response
          if @error_message
            Oslc::Error.new(400, @error_message).to_rdfxml
          else
            if @test_case.errors.empty?
              Tmt::XML::RDFXML.new(xmlns: {
                dcterms: :dcterms,
                rdf: :rdf
              }, xml: {land: :en}) do |xml|
                xml.add("dcterms:identifier") { @test_case.id.to_s }
              end.to_xml
            else
              message = @test_case.errors.full_messages.join('. ')
              Oslc::Error.new(400, message).to_rdfxml
            end
          end
        end

        def parse
          result = {}
          doc = Nokogiri::XML.parse(@xml_content)
          result[:description] = doc.xpath("//dcterms:description").text
          result[:name] = doc.xpath("//dcterms:title").text
          result
        end

        def update
          # https://jazz.net/library/article/1197
        end
      end
    end
  end
end
