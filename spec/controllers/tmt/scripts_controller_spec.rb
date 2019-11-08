require 'spec_helper'

describe Tmt::ScriptsController do
  extend CanCanHelper

  let(:admin) { create(:admin) }

  let(:user) { create(:user) }

  let(:project) do
    project = create(:project, creator: user)
    project.add_member(user)
    project
  end

  before do
    ready(project)
  end

  describe "GET Show" do
    it_should_not_authorize(self, [:no_logged]) do
      get :show
    end

    it "should authorize if user has logged" do
      sign_in user
      get :show
      assigns(:projects).should eq([project])
    end

  end

  describe "POST execute" do
    describe "for import_version" do
      it_should_not_authorize(self, [:no_logged, :foreign]) do
        post :execute, script: {engine: 'import_versions', project_id: project.id.to_s}
      end

      it "should download empty list of test cases from project " do
        sign_in user
        post :execute, {script: {engine: 'import_versions', project_id: project.id}}
        response.header['Content-Type'].should eq('application/octet-stream')
        response.header['Content-Disposition'].should match('.zip')
      end

      it "should download zip file of test cases of project" do
        sign_in user
        test_case = create(:test_case_with_type_file, project: project)
        create(:test_case_version_with_revision, test_case: test_case)
        post :execute, {script: {engine: 'import_versions', project_id: project.id}}
        response.header['Content-Type'].should eq('application/octet-stream')
        response.header['Content-Disposition'].should match('.zip')
      end

    end
  end
end
