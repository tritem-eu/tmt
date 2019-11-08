require 'spec_helper'

describe Oslc::Automation::ResultsController do
  include Support::Oslc::Controllers::Resource
  extend CanCanHelper

  let(:user) { create(:user) }

  let(:execution) { create(:execution) }


  let(:test_run) do
    test_run = execution.test_run
    test_run.update(executor: user)
    test_run.set_status_planned
    test_run
  end

  let(:project) do
    project = execution.project
    project.add_member(user)
    project
  end

  let(:xml) { Nokogiri::XML(response.body) }

  let(:valid_content) do
    Tmt::XML::RDFXML.new(xmlns: {
      oslc_auto: :oslc_auto,
      rdf: :rdf,
      dcterms: :dcterms
    }, xml: {lang: :en}) do |xml|
      xml.add("oslc_auto:producedByAutomationRequest", rdf: {resource: oslc_automation_service_provider_request_url(project, execution)})
      xml.add("oslc_auto:state", rdf: {resource: 'http://open-services.net/ns/auto#complete'})
      xml.add("oslc_auto:verdict", rdf: {resource: 'http://open-services.net/ns/auto#error'})
      xml.add("dcterms:title") {"Automation Result - X"}
      xml.add("oslc_auto:contribution", rdf: {parseType: "XMLLiteral"}) { "Error: Incorrect File!"}
      xml.add("rdf:type", rdf: {resource: 'http://open-services.net/ns/auto#AutomationResult'})
    end.to_xml
  end

  before do
    ready(project, user, test_run, execution)
  end

  [
    ['application/rdf+xml', :rdf],
    ['application/xml', :xml]
  ].each do |content_type, format|
    describe "POST create for format #{format} (The User isn't logged)" do
      it_should_not_authorize(self, [:no_logged, :foreign], auth: :basic, format: format) do |options|
        post :create, valid_content, content_type: content_type, service_provider_id: project.id, format: format
      end
    end

    describe "POST create for format #{format}" do
      before do
        http_login(user)
      end

      it "should update execution entry" do
        post :create, valid_content, content_type: content_type, service_provider_id: project.id, format: format
        response.status.should eq(201)
        execution = Tmt::Execution.first
        execution.status.should eq('error')
        execution.comment.should eq('Automation Result - X')
        file_path = Tmt::Execution.first.attached_files[0][:server_path]
        Tmt::Lib::Gzip.decompress_from(file_path).should eq('Error: Incorrect File!')
      end

      it "render xml content with message about invalid operation" do
        post :create, "", content_type: content_type, service_provider_id: project.id
        xml.xpath('//oslc:statusCode').text.should eq('500')
        xml.xpath('//oslc:message').text.should eq("Internal Server Error Couldn't find Tmt::Execution without an ID")
        response.status.should eq(500)
      end
    end
  end

  it_should_behave_like "GET 'show' for OSLC resource" do
    let(:type) {"oslc_auto:AutomationResult"}
    let(:user_to_log) { user }
    let(:resource) { execution }
  end

  it_should_behave_like "GET query for OSLC resources" do
    let(:type) {"oslc_auto:AutomationResult"}
    let(:user_to_log) { user }
    let(:resources_from_project) do
      [
        execution,
        create(:execution, test_run: test_run)
      ]
    end
    let(:foreign_resource) do
      create :execution
    end
    let(:dcterms_identifier) do
      server_url("/oslc/automation/service-providers/#{project.id}/results/#{execution.id}")
    end
  end

end
