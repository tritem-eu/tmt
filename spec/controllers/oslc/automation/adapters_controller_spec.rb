require 'spec_helper'

describe Oslc::Automation::AdaptersController do
  include Support::Oslc::Controllers::Resource
  extend CanCanHelper

  let(:admin) { create(:admin) }

  let(:user) { create(:user) }

  let(:project) do
    project = create(:project, {name: "MyString", creator_id: admin.id} )
    project.add_member(user)
    project
  end

  let(:xml) { Nokogiri::XML(response.body) }

  let(:adapter_for_windows) do
    create(:automation_adapter,
      project: project,
      description: 'This adapter is for Windows system.',
      polling_interval: 7
    )
  end

  let(:adapter_for_ubuntu) do
    create(:automation_adapter,
      project: project,
      description: 'This adapter is for Ubuntu system.',
      name: 'title 03.11.2014 09:28',
      polling_interval: 3
    )
  end

  before do
    ready(project, user)
  end

  [
    ['application/rdf+xml', :rdf],
    ['application/xml', :xml]
  ].each do |content_type, format|
    describe "POST create for format #{format} (The User isn't logged)" do
      it_should_not_authorize(self, [:no_logged, :foreign], auth: :basic, format: format) do |options|
        ready(project)
        expect do
          post :create, '', content_type: content_type, service_provider_id: project.id, format: format
        end.to change(Tmt::AutomationAdapter, :count).by(0)
      end
    end

    describe "POST create for format #{format}" do
      let(:valid_content) do
        Tmt::XML::RDFXML.new(xmlns: {
          dcterms: :dcterms,
          rdf: :rdf,
          rqm_auto: :rqm_auto
        }, xml: {lang: :en}) do |xml|
          xml.add "rdf:type", rdf: {resource: 'http://jazz.net/ns/auto/rqm#AutomationAdapter'}
          xml.add("dcterms:description") { "description of resource" }
          xml.add("dcterms:title") { "title of resource" }
          xml.add("dcterms:type") {Tmt.config[:oslc][:execution_adapter_type][:id]}
          xml.add("rqm_auto:pollingInterval") { "7" }
        end.to_xml
      end

      let(:invalid_content) do
        Tmt::XML::RDFXML.new(xmlns: {
          dcterms: :dcterms,
          rdf: :rdf,
          rqm_auto: :rqm_auto,
          oslc: :oslc
        }, xml: {lang: :en}) do |xml|
          xml.add("dcterms:description") { "description of resource" }
          xml.add("dcterms:title") { "" }
          xml.add("dcterms:type") { Tmt.config[:oslc][:execution_adapter_type][:id] }
          xml.add("rdf:type", rdf: {resource: 'http://jazz.net/ns/auto/rqm#AutomationAdapter'})
        end.to_xml
      end

      before do
        ready(project)
        http_login(user)
      end

      it "should create a new automation adapter when content is properly" do
        Tmt::AutomationAdapter.delete_all
        expect do
          post :create, valid_content, content_type: content_type, service_provider_id: project.id, format: format
        end.to change(Tmt::AutomationAdapter, :count).by(1)
        adapter = Tmt::AutomationAdapter.first
        adapter.name.should eq("title of resource")
        adapter.description.should eq("description of resource")
        adapter.adapter_type.should eq Tmt.config[:oslc][:execution_adapter_type][:id]
        adapter.polling_interval.should eq(7)
      end

      it "render xml content with id of a new automation adapter" do
        post :create, valid_content, content_type: content_type, service_provider_id: project.id, format: format
        xml.xpath('//dcterms:identifier').text.should eq(Tmt::AutomationAdapter.last.id.to_s)
        response.status.should eq(201)
      end

      it "should not create a new automation adapter when content has blank name" do
        expect do
          post :create, invalid_content, content_type: content_type, service_provider_id: project.id, format: format
        end.to change(Tmt::AutomationAdapter, :count).by(0)
      end

      it "render xml content with message about invalid operation" do
        post :create, invalid_content, content_type: content_type, service_provider_id: project.id, format: format
        xml.xpath('//oslc:statusCode').text.should eq('400')
        xml.xpath('//oslc:message').text.should eq("'//rqm_auto:pollingInterval' selector cannot be parsed")
        response.status.should eq(400)
      end

      it "render status 400 when content is blank" do
        post :create, '', content_type: content_type, service_provider_id: project.id, format: format
        xml.xpath('//oslc:statusCode').text.should eq('400')
        xml.xpath('//oslc:message').text.should eq("Type of content is incorrect")
        response.status.should eq(400)
      end

    end
  end

  it_should_behave_like "GET 'show' for OSLC resource" do
    let(:type) {"rqm_auto:AutomationAdapter"}
    let(:user_to_log) { user }
    let(:resource) do
      create(:automation_adapter,
        project: project,
        description: 'Description of resource',
        polling_interval: 7
      )
    end
  end

  it_should_behave_like "GET query for OSLC resources" do
    let(:type) {"rqm_auto:AutomationAdapter"}
    let(:user_to_log) { user }
    let(:resources_from_project) do
      [
        adapter_for_ubuntu,
        adapter_for_windows
      ]
    end
    let(:foreign_resource) do
      create :automation_adapter
    end
    let(:dcterms_identifier) do
      server_url "/oslc/automaiton/service-providers/#{project.id}/adapters/#{adapter_for_ubuntu.id}"
    end
  end

end
