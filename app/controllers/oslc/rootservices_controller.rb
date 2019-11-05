class Oslc::RootservicesController < ApplicationController

  # GET /rootservices
  def show
    response.headers['OSLC-Core-Version'] = '2.0'
    case request.format.symbol
    when :rdf
      response.headers['Content-Type'] = 'application/rdf+xml'
    else
      response.headers['Content-Type'] = 'application/xml'
    end

    result = ::Oslc::Rootservices.new.to_rdfxml
    respond_to do |format|
      format.html { render text: result }
      format.rdf { render text: result }
      format.xml { render text: result }
    end
  end

end
