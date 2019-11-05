# Update Test Case
#
# Example:
#   https://jazz.net/library/article/1197
module Oslc
  module Core
    # It is framework to modify attributes of models.
    # Each classes which inherit this framework should be used 'after_initialize' method.
    # For example:
    # class DummyResource::Modify < Oslc::Core::Modify
    #   after_initialize do
    #     doc = Nokogiri::XML.parse()
    #     begin
    #       doc = Nokogiri::XML.parse(@xml_conent)
    #       @object.progress = doc.xpath('//rqm_auto:progress').text
    #     rescue => e
    #       @error_message = e.message
    #     end

    #     @render_result = -> { ::Oslc::Automation::Request::resource.new(@controller, @object).to_rdfxml }
    #   end
    # end

    # where @resource_class variable is class which inherity methods from Oslc::Core::Resource class
    class Modify

      attr_reader :status, :response

      def self.after_initialize &handler
        define_method 'after_initialize' do
          self.instance_eval(&handler)
        end
      end

      def initialize(xml_content, options={})
        @routes = Oslc::Core::Routes.get_singleton
        @options = options
        @xml_content = xml_content
        @project = options[:project]
        @object = options[:object]
        @if_match = options[:if_match]
        #@etag = Digest::MD5.hexdigest(@test_case.cache_key)
        @error_message = nil
        after_initialize
      rescue => e
        @error_message = e.message
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

      def parse_type
        read_resource('//rdf:type')
      rescue
        nil
      end

      def update
        if @error_message.nil?
          @object.save
          if @object.errors.empty?
            @status = 200
            @response = ''
          else
            message = @object.errors.full_messages.join('. ')
            @status = 409
            @response = Oslc::Error.new(@status, message).to_rdfxml
          end
        else
          @status = 400
          @response = Oslc::Error.new(@status, @error_message).to_rdfxml
        end
      end

     #def generate_response
     #  if @if_match.blank?
     #    @status = 400
     #    @respons = Oslc::Error.new(@status, "If_Match header is missing").to_rdfxml
     #  else
     #    if @if_match == @etag
     #      if @error_message
     #        @status = 409
     #        @response = Oslc::Error.new(@status, @error_message).to_rdfxml
     #      else
     #        if @test_case.errors.empty?
     #          @status = 200
     #          @response = ::Oslc::Qm::TestCase::Resource.new(@test_case, @controller).to_rdfxml
     #        else
     #          message = @test_case.errors.full_messages.join('. ')
     #          @status = 409
     #          @response = Oslc::Error.new(@status, message).to_rdfxml
     #        end
     #      end
     #    else
     #      @status = 412
     #      @response = Oslc::Error.new(@status, "If_Match header does not match with ETag header").to_rdfxml
     #    end
     #  end
     #end
    end
  end
end
