# About authenticate:
#   http://open-services.net/bin/view/Main/OslcCoreSpecification?sortcol=table;up=#Authentication
class Oslc::BaseController < ApplicationController
  # HTTP Basic Authentication SHOULD do so only via SSL
  before_action :http_basic_authenticate

  def get_request_accept
    if ['application/xml', 'application/rdf+xml', 'application/atom+xml', 'application/json'].include?(request.headers['Accept'])
      request.headers['Accept']
    else
      'application/rdf+xml'
    end
  end

  def respond_rdf(&block)
    if get_request_accept == 'application/rdf+xml'
      response.headers['OSLC-Core-Version'] = '2.0'
      response.headers['Content-Type'] = 'application/rdf+xml'
      block.call
    end
  end

  def respond_xml(&block)
    if get_request_accept == 'application/xml'
      response.headers['OSLC-Core-Version'] = '2.0'
      response.headers['Content-Type'] = 'application/xml'
      block.call
    end
  end

  def respond_atom(&block)
    if get_request_accept == 'application/atom+xml'
      response.headers['OSLC-Core-Version'] = '2.0'
      response.headers['Content-Type'] = 'application/atom+xml'
      block.call
    end
  end

  skip_before_filter :verify_authenticity_token

  # Return response for UIDialog like on page http://open-services.net/bin/view/Main/OslcCoreSpecification#Delegated_User_Interface_Dialogs#ResourceSelection
  # Example:
  #   selection_dialog_response(@test_cases, :name, :oslc_qm_service_provider_test_case_url, [@service_provider, nil]))
  # value nil is current record in generator
  def selection_dialog_response(records, method_title, method_url, url_arguments=[])
    result = %Q|oslc-response: {\"oslc:results\" \: [|
    result += records.map do |record|
      arguments = url_arguments.map do |value|
        if value =~ /nil\./
          record.send(value.sub('nil.', ''))
        elsif value.nil?
          record
        else
          value
        end
      end

      "{ \"oslc:label\" : \"#{record.send(method_title)}\", \"rdf:resource\" : \"#{send(method_url, *arguments)}\"}"
    end.join(",")
    result += "]}"
    result
  end

  # Handle error exceptions
  rescue_from ActiveRecord::RecordNotFound do |exception|
    message = ::Oslc::Error.new(500, "Internal Server Error #{exception.message}").to_rdfxml
    respond_xml {render text: message, status: 500}
    respond_rdf {render text: message, status: 500}
  end

  # input:
  #   model_or_content: ActiveRecord object which has got 'cache_key' method or strint
  # return: nil and set ETag in header
  def add_etag(model_or_content)
    if defined?(model_or_content.cache_key)
      content = model_or_content.cache_key
    else
      content = model_or_content
    end
    response.headers['ETag'] = Digest::MD5.hexdigest(content)
  end

  private

  # input:
  #   object: object to verified
  # output:
  #   return content of status 404 when object is nil or has used deleted_at attribute
  def when_exist(object, &block)
    if object.nil? or (defined?(object.deleted_at) and not object.deleted_at.nil?)
      xml = Oslc::Error.new(404, "Not Found").to_rdfxml
      respond_to do |format|
        format.xml {render text: xml, status: 404}
        format.rdf {render text: xml, status: 404}
      end
    else
      block.call
    end
  end

end
