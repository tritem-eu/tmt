require 'spec_helper'

describe Oslc::Automation::RequestsController do
  include Support::Oslc::Controllers::Resource
  include Support::Oslc::Controllers::Resources
  extend CanCanHelper

  let(:admin) { create(:admin) }

  let(:automation_adapter) do
    Tmt::AutomationAdapter.create(
      project: project,
      description: 'Description of resource',
      name: 'title 03.11.2014 09:28',
      adapter_type: 'AX Type',
      user: user,
      polling_interval: 7
    )
  end

  let(:test_run) do
    test_run = execution.test_run
    test_run.status = 2
    test_run.save(validate: false)
    test_run
  end
  let(:execution) { create(:execution) }
  let(:another_execution) { create(:execution, test_run: test_run) }
  let(:project) { test_run.project}
  let(:user) do
    user = create(:user)
    project.add_member(user)
    user
  end

  let(:user_but_not_executor) do
    user = create(:user)
    project.add_member(user)
    user
  end

  let(:xml) { Nokogiri::XML(response.body)}

  before do
    ready(project, user)
  end

  it_should_behave_like "GET 'show' for OSLC resource" do
    let(:type) {"oslc_auto:AutomationRequest"}
    let(:user_to_log) { user }
    let(:resource) { execution }
  end

  it_should_behave_like "GET query for OSLC resources" do
    let(:type) {"oslc_auto:AutomationRequest"}
    let(:user_to_log) { user }
    let(:resources_from_project) do
      [
        execution,
        another_execution
      ]
    end
    let(:foreign_resource) do
      create :execution
    end
    let(:dcterms_identifier) do
      server_url("/oslc/automation/service-providers/#{project.id}/requests/#{execution.id}")
    end
  end

  describe "PUT update" do
    [
      ['application/rdf+xml', :rdf],
      ['application/xml', :xml]
    ].each do |content_type, format|

      let(:valid_content) do
        Tmt::XML::RDFXML.new(xmlns: {
          rdf: :rdf,
          rqm_auto: :rqm_auto
        }, xml: {lang: :en}) do |xml|
          xml.add("rqm_auto:progress") {23}
          xml.add "rdf:type", rdf: {resource: 'http://open-services.net/ns/auto#AutomationRequest'}
        end.to_xml
      end

      let(:invalid_content) do
        Tmt::XML::RDFXML.new(xmlns: {
          rdf: :rdf,
          rqm_auto: :rqm_auto
        }, xml: {lang: :en}) do |xml|
          xml.add("rqm_auto:progress") {23}
        end.to_xml
      end

      describe "PUT update for format #{format} (The User isn't logged)" do
        it_should_not_authorize(self, [:no_logged, :foreign, 'self.user_but_not_executor'], auth: :basic, format: format) do |options|
          ready(project, automation_adapter, execution, user)
          test_run.update(executor: user).should be true
          test_run.set_status_planned
          put :update, valid_content, {content_type: content_type, service_provider_id: project.id, id: execution.id, format: format}
        end
      end

      describe "PUT update for format #{format} (The user is logged)" do
        before do
          ready(project, automation_adapter, execution, user)
          http_login(user)
        end

        it "should update existing execution where test run has 'planned' status" do
          test_run.update(executor: user).should be true
          test_run.set_status_planned
          request.headers['content-type'] = content_type
          put :update, valid_content, {content_type: content_type, service_provider_id: project.id, id: execution.id}
          response.status.should eq(200)
          response.body.should eq('')
        end

        it "should update existing execution where test run has 'done' status" do
          test_run.update(executor: user).should be true
          test_run.set_status_planned
          request.headers['content-type'] = content_type
          execution.status = Tmt::Execution::STATUS_PASSED
          execution.save(validate: false)
          test_run.reload.status.should eq(Tmt::TestRun::STATUS_DONE)
          execution.progress.should eq(0)
          put :update, valid_content, {content_type: content_type, service_provider_id: project.id, id: execution.id}
          execution.progress.should eq(0)
          response.status.should eq(200)
          response.body.should eq('')
        end

        it "should not update existing execution when xml content is invalid" do
          test_run.update(executor: user).should be true
          test_run.set_status_planned
          put :update, invalid_content, {content_type: content_type, service_provider_id: project.id, id: execution.id, format: format}
          response.status.should eq(400)
          Nokogiri.parse(response.body).xpath("//oslc:statusCode").text.should eq('400')
          execution.reload.progress.should eq(0)
        end
      end
    end
  end
end
