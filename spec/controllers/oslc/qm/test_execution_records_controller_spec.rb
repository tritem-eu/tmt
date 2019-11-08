require 'spec_helper'

describe Oslc::Qm::TestExecutionRecordsController do
  include Support::Oslc::Controllers::Resource
  extend CanCanHelper

  let(:oliver) { create(:user) }
  let(:user) { create(:user) }

  let(:john) do
    create(:user)
  end

  let(:type) {create(:test_case_type, name: "default")}
  let(:valid_attributes) { { "name" => "MyString", creator_id: user.id } }

  let(:project) do
    project = create(:project, valid_attributes)
    project.add_member(john)
    project.add_member(oliver)
    project
  end

  let(:campaign) { create(:campaign, project: project) }

  let(:test_run) { create(:test_run, campaign: campaign, executor: john) }
  let(:test_case) { create(:test_case, project: project)}
  let(:version) { create(:test_case_version, test_case: test_case) }
  let(:execution) { ::Tmt::Execution.create(test_run: test_run, version: version) }

  before do
    ready(execution, project)
  end

  it_should_behave_like "GET 'show' for OSLC resource" do
    let(:type) {"oslc_qm:TestExecutionRecord"}
    let(:user_to_log) { oliver }
    let(:resource) do
      execution
    end
  end

  it_should_behave_like "GET query for OSLC resources" do
    let(:type) {"oslc_qm:TestExecutionRecord"}
    let(:user_to_log) { oliver }
    let(:resources_from_project) do
      [
        execution,
        create(:execution, test_run: test_run, version: version)
      ]
    end

    let(:foreign_resource) do
      create(:execution)
    end

    let(:dcterms_identifier) do
      "#{server_url}/oslc/qm/service-providers/#{project.id}/test-execution_record/#{execution.id}"
    end
  end

  it "GET #selection_dialog" do
    http_login(john)
    get :selection_dialog, service_provider_id: project.id
    assigns(:response).should match(/oslc-response:/)
  end

end
