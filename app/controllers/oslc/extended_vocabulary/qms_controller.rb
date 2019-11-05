# About authenticate:
#   http://open-services.net/bin/view/Main/OslcCoreSpecification?sortcol=table;up=#Authentication
module Oslc
  class ExtendedVocabulary::QmsController < ApplicationController
    skip_before_filter :verify_authenticity_token

    def show
      response.headers['OSLC-Core-Version'] = '2.0'
      case request.format.symbol
      when :rdf
        response.headers['Content-Type'] = 'application/rdf+xml'
      else
        response.headers['Content-Type'] = 'application/xml'
      end

      xml = ::Oslc::ExtendedVocabulary::Qm.new(self).to_xml
      respond_to do |format|
        format.rdf { render text: xml, :disposition => "inline"}
        format.xml {render text: xml, :disposition => "inline"}
      end
    end

  end
end
