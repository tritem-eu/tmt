# Specification:
#   http://open-services.net/bin/view/Main/OslcCoreSpecification#Error_Responses
# Example:
#   http://open-services.net/wiki/architecture-management/OSLC-Architecture-Management-2.0-Appendix-A:-Samples/
class Oslc::Error

  def initialize(statusCode, message=nil)
    @statusCode = statusCode
    @message = message || message_for_status(statusCode)
  end

  def to_rdfxml
    Tmt::XML::RDFXML.new(xmlns: {
      rdf: :rdf,
      oslc: :oslc
    }) do |xml|
      xml.add("oslc:Error") do |xml|
        xml.add("oslc:statusCode") { @statusCode }
        xml.add("oslc:message") { @message }
      end
    end.to_xml
  end

  def to_xml
    to_rdfxml
  end

  def to_rdf
    to_rdfxml
  end

  private

  # 200 Success
  # 201 Success. The response contains a link.
  # 204 Resource successfully updated. There is no response entity.
  # 400 Error handling request. This error might be due to the request content or URI. For example, there might be a business logic validation error on the server side.
  # 401 Authentication failure.
  # 403 Forbidden. The user password expired.
  # 404 Resource cannot be found or an invalid resource type was provided.
  # 405 HTTP method cannot be used for the resource.
  # 406 Requested representation is not supported.
  # 410 Stable resource page expired.
  # 412 Resource on the client side is stale and must be refreshed from the server. The conditional update failed because the resource was updated by another user or process.
  # 500 All other server errors.
  def message_for_status(statusCode)
    case statusCode
    when 200
    when 201
    when 401
      'HTTP Basic: Access denied.\n'
    else

    end
  end

end
