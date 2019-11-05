# Update Test Case
#
# Example:
#   https://jazz.net/library/article/1197
module Oslc
  module Qm
    module TestCase
      class Modify

        attr_reader :test_case, :status, :response

        def initialize(xml_content, options={})
          @xml_content = xml_content
          @project = options[:project]
          @creator = options[:current_user]
          @test_case = options[:test_case]
          @if_match = options[:if_match]
          @controller = options[:controller]
          @etag = Digest::MD5.hexdigest(@test_case.cache_key)
          @error_message = nil
          prepare_test_case
        end

        def prepare_test_case
          doc = Nokogiri::XML.parse(@xml_content)
          @test_case.description = doc.xpath("//dcterms:description").text
          @test_case.name = doc.xpath("//dcterms:title").text
        rescue => e
          @error_message = e.message
        end

        def update
          return false if @error_message == true
          @test_case.save
          generate_response
        end

        def generate_response
          if @if_match.blank?
            @status = 400
            @respons = Oslc::Error.new(@status, "If_Match header is missing").to_rdfxml
          else
            if @if_match == @etag
              if @error_message
                @status = 409
                @response = Oslc::Error.new(@status, @error_message).to_rdfxml
              else
                if @test_case.errors.empty?
                  @status = 200
                  @response = ::Oslc::Qm::TestCase::Resource.new(@test_case, @controller).to_rdfxml
                else
                  message = @test_case.errors.full_messages.join('. ')
                  @status = 409
                  @response = Oslc::Error.new(@status, message).to_rdfxml
                end
              end
            else
              @status = 412
              @response = Oslc::Error.new(@status, "If_Match header does not match with ETag header").to_rdfxml
            end
          end
        end
      end
    end
  end
end
