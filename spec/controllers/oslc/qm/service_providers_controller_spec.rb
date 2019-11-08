require 'spec_helper'

describe Oslc::Qm::ServiceProvidersController do
  extend CanCanHelper

  let(:admin) { create(:admin) }

  let(:member) do
    member = create(:user)
    project.add_member(member)
    member
  end

  let(:project) { create(:project) }

  let(:xml) { Nokogiri::XML(response.body) }

  before do
    ready(admin, member, project)
  end

  [[:rdf, 'application/rdf+xml'], [:xml, 'application/xml']].each do |format, accept|
    describe "GET index for format: #{format}" do
      it_should_not_authorize(self, [:no_logged], auth: :basic, format: format) do |options|
        request.headers[:accept] = accept
        get :index, format: options[:format]
      end

      it "should collect projects where current_user is John" do
        http_login(member)
        get :index, format: format
        spc = '//oslc:ServiceProviderCatalog'
        url = server_url "/oslc/qm/service-providers"
        xml.at_xpath(spc).attributes["about"].value.should eq url
        xml.at_xpath("#{spc}//dcterms:title").text.should eq('TMT QM Service Provider Catalog')
        xml.at_xpath("#{spc}//dcterms:description").text.should eq('TMT QM Service Provider Catalog')
        xml.at_xpath("#{spc}//dcterms:publisher").should_not be_nil
        sp = "#{spc}//oslc:serviceProvider//oslc:ServiceProvider"
        url = server_url "/oslc/qm/service-providers/#{project.id}"
        xml.at_xpath(sp).attributes['about'].value.should eq url
        xml.at_xpath("#{sp}//dcterms:title").text.should eq(project.name)
        xml.at_xpath("#{sp}//dcterms:description").text.should eq(project.description.to_s)
        url = server_url("/projects/#{project.id}")
        xml.at_xpath("#{sp}//oslc:details").to_s.should eq("<oslc:details rdf:resource=\"#{url}\"/>")
      end
    end
  end

  [:rdf, :xml, :atom].each do |format|
    describe "GET show for format: #{format}" do

      it_should_not_authorize(self, [:no_logged, :foreign], auth: :basic, format: format) do |options|
        get :show, id: project.id, format: options[:format]
      end

      describe "for logged user" do

        before do
          http_login(member)
          get :show, id: project.id, format: format
          def xml.query_capability(selector)
            self.xpath("//oslc:queryCapability//oslc:QueryCapability#{selector}").to_s
          end

          def xml.creation_factory(selector)
            self.xpath("//oslc:creationFactory//oslc:CreationFactory#{selector}").to_s
          end

        end

        it "should authorize where current_user is a member" do
          xml.xpath("//rdf:RDF").should_not be_empty
          response.status.should eq 200
        end

        describe "Query Capability for Test Plan, Test Case, Test Script, Test Result and Test Execution Record" do
          it "should have dcterms:title selector" do
            xml.query_capability('//dcterms:title').should include("OSLC QM - Query Test Plan")
            xml.query_capability('//dcterms:title').should include("OSLC QM - Query Test Execution Record")
            xml.query_capability('//dcterms:title').should include("OSLC QM - Query Test Case")
            xml.query_capability('//dcterms:title').should include("OSLC QM - Query Test Script")
            xml.query_capability('//dcterms:title').should include("OSLC QM - Query Test Result")
          end

          it "should have oslc:label selector" do
            xml.query_capability('//oslc:label').should include("Query Test Plan")
            xml.query_capability('//oslc:label').should include("Query Test Execution Record")
            xml.query_capability('//oslc:label').should include("Query Test Case")
            xml.query_capability('//oslc:label').should include("Query Test Script")
            xml.query_capability('//oslc:label').should include("Query Test Result")
          end

          it "should have oslc:queryBase selector" do
            xml.query_capability('//oslc:queryBase').should match(/rdf:resource=\"http.*\/oslc\/qm\/service-providers\/#{project.id}\/test-plans\/query/)
            xml.query_capability('//oslc:queryBase').should match(/rdf:resource=\"http.*\/oslc\/qm\/service-providers\/#{project.id}\/test-execution-records\/query/)
            xml.query_capability('//oslc:queryBase').should match(/rdf:resource=\"http.*\/oslc\/qm\/service-providers\/#{project.id}\/test-cases\/query/)
            xml.query_capability('//oslc:queryBase').should match(/rdf:resource=\"http.*\/oslc\/qm\/service-providers\/#{project.id}\/test-scripts\/query/)
            xml.query_capability('//oslc:queryBase').should match(/rdf:resource=\"http.*\/oslc\/qm\/service-providers\/#{project.id}\/test-results\/query/)
          end

          it "should have oslc:resourceShape selector" do
            xml.query_capability('//oslc:resourceShape').should match(/rdf:resource=\"http.*\/oslc\/qm\/resource-shapes\/test-run/)
            xml.query_capability('//oslc:resourceShape').should match(/rdf:resource=\"http.*\/oslc\/qm\/resource-shapes\/test-execution-record/)
            xml.query_capability('//oslc:resourceShape').should match(/rdf:resource=\"http.*\/oslc\/qm\/resource-shapes\/test-case/)
            xml.query_capability('//oslc:resourceShape').should match(/rdf:resource=\"http.*\/oslc\/qm\/resource-shapes\/test-script/)
            xml.query_capability('//oslc:resourceShape').should match(/rdf:resource=\"http.*\/oslc\/qm\/resource-shapes\/test-result/)
          end

          it "should have oslc:resourceType selector" do
            xml.query_capability('//oslc:resourceType').should match(/rdf:resource=\"http:\/\/open-services.net\/ns\/qm#TestPlan/)
            xml.query_capability('//oslc:resourceType').should match(/rdf:resource=\"http:\/\/open-services.net\/ns\/qm#TestExecutionRecord/)
            xml.query_capability('//oslc:resourceType').should match(/rdf:resource=\"http:\/\/open-services.net\/ns\/qm#TestCase/)
            xml.query_capability('//oslc:resourceType').should match(/rdf:resource=\"http:\/\/open-services.net\/ns\/qm#TestScript/)
            xml.query_capability('//oslc:resourceType').should match(/rdf:resource=\"http:\/\/open-services.net\/ns\/qm#TestResult/)
          end

          it "should have oslc:usage selector" do
            xml.query_capability('//oslc:usage').should match(/rdf:resource=\"http:\/\/open-services.net\/ns\/core#default/)
          end

        end

        describe "Query Capability for Test Case" do
          it "should have dcterms:title selector" do
            xml.creation_factory('//dcterms:title').should include("Creating Test Case (OSLC QM)")
          end

          it "should have oslc:label selector" do
            xml.creation_factory('//oslc:label').should include("Creation Factory for Test Case")
          end

          it "should have oslc:creation selector" do
            xml.creation_factory('//oslc:creation').should match(/rdf:resource="http:.*\/oslc\/qm\/service-providers\/#{project.id}\/test-cases/)
          end

          it "should have oslc:resourceShape selector" do
            xml.creation_factory('//oslc:resourceShape').should match(/rdf:resource="http:.*\/oslc\/qm\/resource-shapes\/test-case/)
          end

        end

      end
    end
  end

end
