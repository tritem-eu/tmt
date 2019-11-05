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
  module Automation
    module Result
      class CreationFactory < ::Oslc::Core::CreationFactory
        require 'tempfile'

        include Rails.application.routes.url_helpers

        def after_initialize
          @type = 'http://open-services.net/ns/auto#AutomationResult'
          check_type
          @project = @options[:project]
          @object = Tmt::Execution.where(id: automation_request_id).first
          if @object.executed?
            raise StandardError, "Automation Result was previously created"
          end
          set_contribution
          set_status
          set_title
        end

        def automation_request_id
          parse_automation_request_url.to_s.split('/').last.to_i
        rescue
          nil
        end

        private

        def set_status
          verdict = parse_verdict
          state = parse_state
          state_and_verdict = ::Oslc::Core::Properties::StateAndVerdict.new(state, verdict)
          status = state_and_verdict.map_to_execution_status
          if not status == nil
            @object.status = status
          else
            raise StandardError, "Type of content has incorrect 'state' or 'verdict' values."
          end
        end

        def parse_state
          read_resource('//oslc_auto:state')
        end

        def parse_verdict
          read_resource('//oslc_auto:verdict')
        end


        def parse_automation_request_url
          read_resource('//oslc_auto:producedByAutomationRequest')
        end

        def set_title
          result = parse_title
          if not result.nil?
            @object.comment = parse_title
          end
        end

        def parse_title
          if @xml_content.include?('dcterms:title')
            @doc.xpath("//dcterms:title").text
          end
        end

        def set_contribution
          file = Tempfile.new('comment')
          file.write(parse_contribution)
          file.rewind
          @object.datafiles = [::ActionDispatch::Http::UploadedFile.new({
            filename: "result",
            content_type: 'text/plain',
            tempfile: file
          })]
        end

        def parse_contribution
          @doc.xpath("//oslc_auto:contribution").text
        end

      end
    end
  end
end
