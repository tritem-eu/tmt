class Oslc::ErrorsController < ApplicationController
  skip_before_filter :verify_authenticity_token

  def show
    rdfxml = ::Oslc::Error.new(params[:status_code]).to_rdfxml
    respond_to do |format|
      format.rdf { render text: rdfxml, status: params[:status_code].to_i }
      format.xml { render text: rdfxml, status: params[:status_code].to_i }
    end
  end
end
