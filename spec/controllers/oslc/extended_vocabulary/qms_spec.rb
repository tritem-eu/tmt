require 'spec_helper'

describe Oslc::ExtendedVocabulary::QmsController do

  let(:xml) { Nokogiri::XML(response.body) }

  it "GET #selection_dialog" do
    get :show, format: :rdf
    response.header['Content-Type'].should include('application/rdf+xml')
  end

end
