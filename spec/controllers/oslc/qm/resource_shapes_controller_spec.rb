require 'spec_helper'

describe Oslc::Qm::ResourceShapesController do
  extend CanCanHelper

  let(:admin) { create(:admin) }

  let(:user) { create(:user) }

  let(:xml) { Nokogiri::XML(response.body) }

  [:rdf, :xml].each do |format|
    ['test-case', 'test-plan', 'test-script', 'test-execution-record', 'test-result'].each do |id|
      it_should_not_authorize(self, [:no_logged], auth: :basic, format: :format, id: id) do |options|
        get :show, id: options[:id], format: options[:format]
      end

      describe "GET show for id: #{id}, format: #{format}" do
        before do
          http_login(user)
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
