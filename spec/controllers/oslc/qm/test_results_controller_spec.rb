require 'spec_helper'

describe Oslc::Qm::TestResultsController do
  include Support::Oslc::Controllers::Resource
  include Support::Oslc::Controllers::Resources

  extend CanCanHelper

  let(:admin) { create(:admin) }
  let(:user) { create(:user) }

  let(:executor) do
    executor = create(:user)
    project.add_member(executor)
    executor
  end

  let(:user_from_project) { create(:user) }

  let(:type) {create(:test_case_type, name: "default")}
  let(:valid_attributes) { { "name" => "MyString", creator_id: user.id } }

  let(:project) do
    project = create(:project, valid_attributes)
    project.add_member(user)
    project.add_member(user_from_project)
    project
  end

  let(:campaign) { create(:campaign, project: project) }

  let(:test_run) { create(:test_run, campaign: campaign, executor: executor) }
  let(:test_case) { create(:test_case, project: project)}
  let(:version) { create(:test_case_version, test_case: test_case) }
  let(:next_version) { create(:test_case_version, test_case: create(:test_case, project: project)) }

  let(:execution) { create(:execution, test_run: test_run, version: version) }

  let(:xml) { Nokogiri::XML(response.body) }

  before do
    ready(execution)
  end

  it "GET selection_dialog" do
    http_login(executor)
    get :selection_dialog, service_provider_id: project.id
    assigns(:response).should match(/oslc-response:/)
  end

  [[:rdf, 'application/rdf+xml'], [:xml, 'application/xml']].each do |format, accept|

    describe "PUT #update, format: #{format}" do
      before do
        ready(test_run, execution, campaign)
      end

      it_should_not_authorize(self, [:no_logged, :foreign, 'self.user_from_project', 'self.admin'], auth: :basic) do
        execution.reload.status.should eq('none')
        request.headers['Accept'] = accept
        put :update, service_provider_id: project.id, id: execution.id, status: 'failed', format: format
      end

      it "should not authorize when test_run has got status other than executing" do
        http_login(executor)
        execution.reload.status.should eq('none')
        request.headers['Accept'] = accept
        put :update, service_provider_id: project.id, id: execution.id, status: 'failed', format: format
        execution.reload.status.should eq('none')
      end

      it "should update result" do
        http_login(executor)
        test_run.update(status: 3)
        execution.reload.status.should eq('none')
        put :update, service_provider_id: project.id, id: execution.id, datafiles: [CommonHelper.uploaded_file('short.seq')], status: 'failed', format: format
        execution.reload.status.should eq('failed')
      end

      it "should not update result when it was updated" do
        http_login(executor)
        test_run.update(status: 3)
        execution.update(status: 'failed', comment: 'comment').should be true
        put :update, service_provider_id: project.id, id: execution.id, status: :error, format: format
        execution.reload.status.should_not eq('error')
      end

      it "should not update result when it was updated for file" do
        http_login(executor)
        clean_execution_repository
        test_run.update(status: 3)
        execution.update(status: :failed, datafiles: [upload_file('main_sequence_Report.html')]).should be true
        execution.attached_files.should have(1).item
        put :update, service_provider_id: project.id, id: execution.id, status: "error", datafiles: [upload_file('main_sequence.seq')], format: format
        execution.attached_files.should have(1).item
        execution.attached_files[0][:original_filename].should eq('main_sequence_Report.html')
      end

    end

  end

  it_should_behave_like "GET 'show' for OSLC resource" do
    let(:type) {"oslc_qm:TestResult"}
    let(:user_to_log) { executor }
    let(:resource) { execution}
  end

  it_should_behave_like "GET query for OSLC resources" do
    let(:type) {"oslc_qm:TestResult"}
    let(:user_to_log) { user }
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
      "#{server_url}/oslc/qm/service-providers/#{project.id}/test-results/#{version.id}"
    end
  end

end
