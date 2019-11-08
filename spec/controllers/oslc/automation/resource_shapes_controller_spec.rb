require 'spec_helper'

describe Oslc::Automation::ResourceShapesController do
  extend CanCanHelper

  let(:admin) { create(:admin) }

  let(:user) { create(:user) }

  let(:xml) { Nokogiri::XML(response.body) }

  [
    ['application/rdf+xml', :rdf],
    ['application/xml', :xml]
  ].each do |request_accept, format|
    [:adapter, :request, :result, :plan].each do |id|
      it_should_not_authorize(self, [:no_logged], auth: :basic, format: :format, id: id) do |options|
        request.headers[:accept] = request_accept
        get :show, id: options[:id], format: options[:format]
      end

      describe "GET show for id: #{id}, format: #{format}" do
        before do
          http_login(user)
          request.headers[:accept] = request_accept
          get :show, id: id, format: format

          def xml.property(selector)
            self.xpath(selector)
          end
        end

        it "should include XML structure" do
          xml.xpath("//rdf:RDF").size.should eq(1)
        end

        it "should get 200 status" do
          response.status.should eq(200)
        end
      end
    end
  end
end
