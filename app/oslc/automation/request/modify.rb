module Oslc
  module Automation
    module Request
      class Modify < Oslc::Core::Modify
        include ActionDispatch::Routing::UrlFor

        def after_initialize
          @type = 'http://open-services.net/ns/auto#AutomationRequest'
          @doc = Nokogiri::XML.parse(@xml_content)
          check_type
          set_progress
          if not @object.executed?
            set_status
            set_taken
            @object.comment = "Generated result by OSLC"
          end
        end

        private

        def set_status
          if @xml_content.include?('oslc_auto:state')
            state = get_state
            validate_state(state)
            return nil if @object.executed?
            if @object.status = @object.class::STATUS_NONE
              if not state == Oslc::Core::Properties::Base.state_url('new')
                @object.status = @object.class::STATUS_EXECUTING
              end
            end
          end
        end

        def validate_state(state)
          states = ::Oslc::Core::Properties::Base.state_urls
          if not states.include?(state)
            raise StandardError, "Type of content has incorrect 'state' value."
          end
        end

        def get_state
          return @doc.xpath('//oslc_auto:state')[0].attributes['resource'].value
        rescue
          nil
        end

        def set_taken
          if get_taken == 'true' and @object.status == @object.class::STATUS_NONE
            @object.status = @object.class::STATUS_EXECUTING
          end
        end

        def get_taken
          return @doc.xpath('//rqm_auto:taken').text
        rescue
          nil
        end

        def set_progress
          progress = get_progress
          if not progress == nil
            @object.progress = progress
          end
        end

        def get_progress
          elements = @doc.xpath('//rqm_auto:progress')
          if not elements.empty?
            return elements[0].text
          end
          return nil
        end

      end
    end
  end
end
