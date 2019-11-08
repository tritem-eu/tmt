require 'spec_helper'

describe Oslc::Qm::TestScriptsController do
  extend CanCanHelper
  include Support::Oslc::Controllers::Resource
  include Support::Oslc::Controllers::Resources

  let(:oliver) { create(:user, name: 'Oliver') }

  let(:project) do
    project = create(:project, name: 'MyString', creator: oliver)
    project.add_member(oliver)
    project
  end

  let(:test_case) { create(:test_case, project: project) }

  let(:version) { create(:test_case_version, test_case: test_case) }

  let(:xml) { Nokogiri::XML(response.body) }

  before do
    ready(project)
  end

  it_should_behave_like "GET 'show' for OSLC resource" do
    let(:type) {"oslc_qm:TestScript"}
    let(:user_to_log) { oliver }
    let(:resource) do
      version
    end
  end

  [
    ['application/rdf+xml', :rdf],
    ['application/xml', :xml]
  ].each do |request_accept, format|
    describe "GET #download, format: #{format}" do
      it_should_not_authorize(self, [:no_logged, :foreign], auth: :basic) do
        post :download, service_provider_id: project.id, test_case_id: test_case.id, id: version.id, format: :format
      end

      it "should not authorize when test_run has got status other than executing" do
        http_login(oliver)
        post :download, service_provider_id: project.id, test_case_id: test_case.id, id: version.id, format: :format
      end
    end
  end

  describe "GET #selection_dialog" do
    it_should_not_authorize(self, [:no_logged, :foreign], auth: :basic) do
      get :selection_dialog, service_provider_id: project.id
    end

    it "should authorize member of project" do
      http_login(oliver)
      get :selection_dialog, service_provider_id: project.id
      assigns(:response).should match(/oslc-response:/)
    end
  end

  it_should_behave_like "GET query for OSLC resources" do
    let(:type) {"oslc_qm:TestScript"}
    let(:user_to_log) { oliver }
    let(:resources_from_project) do
      [
        version,
        create(:test_case_version,
          test_case: create(:test_case, project: project)
        )
      ]
    end
    let(:foreign_resource) do
      create(:test_case_version)
    end
    let(:dcterms_identifier) do
      server_url "/oslc/qm/service-providers/#{project.id}/test-scripts/#{version.id}"
    end
  end

end
