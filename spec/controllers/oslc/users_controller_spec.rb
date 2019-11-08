require 'spec_helper'

describe Oslc::UsersController do
  extend CanCanHelper
  let(:user) { create(:user) }

  let(:xml) { Nokogiri::XML(response.body) }

  describe "GET show" do
    [
      ['application/rdf+xml'],
      ['application/xml']
    ].each do |accept|
      it "shows name of user when user is logged; accept: '#{accept}'" do
        http_login(user)
        request.headers[:accept] = accept
        get :show, id: user.id
        response.status.should eq 200
        xml.xpath('//foaf:name').text.should eq(user.name)
      end

      it "doesn't show name of user when user isn't logged; accept: '#{accept}'" do
        request.headers[:accept] = accept
        get :show, id: user.id
        response.status.should eq 401
        response.body.should eq("HTTP Basic: Access denied.\n")
      end
    end
  end
end
