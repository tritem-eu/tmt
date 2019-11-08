require 'spec_helper'

describe Oslc::Qm::TestPlansController do
  extend CanCanHelper

  let(:user) { create(:user) }
  let(:john) { create(:user) }

  let(:admin) do
    user = create(:user)
    user.add_role(:admin)
    user
  end

  let(:type) {create(:test_case_type, name: "default")}
  let(:valid_attributes) { { "name" => "MyString", creator_id: user.id } }

  let(:project) do
    project = create(:project, valid_attributes)
    project.add_member(admin)
    project.add_member(john)
    project
  end

  let(:campaign) { create(:campaign, project: project) }

  let(:test_run) { create(:test_run, campaign: campaign, description: "Description") }
  let(:xml) { Nokogiri::XML(response.body) }

  it_should_behave_like "GET 'show' for OSLC resource" do
    let(:type) {"oslc_qm:TestPlan"}
    let(:user_to_log) { john }
    let(:resource) { test_run }
  end

  it_should_behave_like "GET query for OSLC resources" do
    let(:type) {"oslc_qm:TestPlan"}
    let(:user_to_log) { john }
    let(:resources_from_project) do
      [
        test_run,
        create(:test_run, campaign: campaign, description: "Description")
      ]
    end

    let(:foreign_resource) do
      create(:test_run, description: "Description")
    end

    let(:dcterms_identifier) do
      server_url "/oslc/qm/service-providers/#{project.id}/test-plans/#{test_run.id}"
    end
  end

  it "GET #selection_dialog" do
    http_login(admin)
    ready(project, test_run)

    get :selection_dialog, service_provider_id: project.id
    assigns(:response).should match(/oslc-response:/)
  end

  describe "GET set_status_executing" do
    before do
      http_login(admin)
      ready(project, test_run)
    end

    it "when user is executor" do
      ready(test_run)
      test_run.update(executor: admin)
      create(:execution, test_run: test_run)
      test_run.set_status_planned
      put :set_status_executing, service_provider_id: project.id, id: test_run.id, format: :json
      response.body.should eq({status: 3}.to_json)
    end

    it "when user is executor but invalid operation" do
      ready(test_run)
      test_run.update(executor: admin)
      put :set_status_executing, service_provider_id: project.id, id: test_run.id, format: :json
      response.body.should eq({status: 1}.to_json)
    end

    it "when user isn't executor" do
      ready(test_run)
      put :set_status_executing, service_provider_id: project.id, id: test_run.id, format: :json
      test_run.reload.status.should_not eq(3)
    end
  end

  describe "GET unexecuted" do
    before do
      ready(test_run)
      execution = create(:execution, test_run: test_run)
      test_run.update(executor: admin)
      test_run.versions << create(:test_case_version)
      test_run.update(status: 3)
      http_login(admin)
      ready(project, test_run)
    end

    it "with one execution" do
      test_run.executions.first.update(datafiles: [CommonHelper.uploaded_file('short.seq')], status: :passed)

      get :unexecuted, service_provider_id: project.id, format: :json
      response.body.should eq({
        test_run.id.to_s => [test_run.executions[1].version_id.to_s]
      }.to_json)
    end

    it "with empty list of executions" do
      test_run.executions.map{ |entry| entry.update(datafiles: [CommonHelper.uploaded_file('short.seq')], status: :passed) }
      get :unexecuted, service_provider_id: project.id, format: :json
      response.body.should eq({}.to_json)
    end

  end
end
