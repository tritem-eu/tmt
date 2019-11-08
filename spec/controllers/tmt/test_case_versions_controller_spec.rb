require 'spec_helper'

describe Tmt::TestCaseVersionsController do
  extend CanCanHelper

  let(:user) do
    user = create(:user)
    project.add_member(user)
    user
  end

  let(:test_case) { create(:test_case) }
  let(:project) { test_case.project }

  let(:valid_attributes) {
    {
      author_id: user.id,
      test_case_id: test_case.id,
      comment: "Example comment",
      datafile: upload_file('test_case_version'),
    }
  }

  let(:version) { create(:test_case_version, valid_attributes) }

  describe "GET show" do
    it_should_not_authorize(self, [:no_logged, :foreign]) do
      get :show, {project_id: project.id, test_case_id: test_case.id, id: version.to_param}
    end

    it "assigns the requested test_case_version as @test_case_version" do
      sign_in user
      execution = create(:execution, version: version)
      get :show, {project_id: project.id, test_case_id: test_case.id, id: version.to_param}
      assigns(:version).should eq(version)
      assigns(:project).should eq(project)
      assigns(:test_case).should eq(test_case)
      assigns(:author).should eq(version.author)
      assigns(:executions).should match_array([execution])
      assigns(:dispenser_executions).should be_a(::Tmt::Dispenser)
    end
  end

  describe "GET only_file" do
    it_should_not_authorize(self, [:no_logged, :foreign]) do
      get :only_file, {project_id: project.id, test_case_id: test_case.id, id: version.to_param}
    end

    it "assigns the requested test_case_version as @test_case_version" do
      sign_in user
      execution = create(:execution, version: version)
      get :only_file, {project_id: project.id, test_case_id: test_case.id, id: version.to_param}
      assigns(:version).should eq(version)
      assigns(:project).should eq(project)
      assigns(:test_case).should eq(test_case)
    end
  end

  describe "POST create" do
    describe "with valid params" do
      it_should_not_authorize(self, [:no_logged, :foreign]) do
        post :create, {project_id: project.id, test_case_id: test_case.id, test_case_version: valid_attributes}
      end

      [:js, :html].each do |format|
        it "creates a new TestCaseVersion for format #{format}" do
          sign_in user
          expect do
            post :create, {project_id: project.id, test_case_id: test_case.id, test_case_version: valid_attributes, format: format}
          end.to change(Tmt::TestCaseVersion, :count).by(1)
        end

        it "assigns a newly created test_case_version as @test_case_version for format #{format}" do
          sign_in user
          post :create, {project_id: project.id, test_case_id: test_case.id, :test_case_version => valid_attributes, format: format}
          assigns(:version).should be_a(Tmt::TestCaseVersion)
          assigns(:version).should be_persisted
        end

        it "should show alert for format #{format}" do
          sign_in user
          post :create, {project_id: project.id, test_case_id: test_case.id, :test_case_version => valid_attributes, format: format}
          flash[:notice].should eq('Test Case Version was successfully created')
        end
      end

      it "redirects to the created test_case_version" do
        sign_in user
        post :create, {project_id: project.id, test_case_id: test_case.id, :test_case_version => valid_attributes}
        response.should redirect_to(project_test_case_path(project, test_case))
        response.status.should eq(302)
      end

      it "should have status 200 for format js" do
        sign_in user
        post :create, {project_id: project.id, test_case_id: test_case.id, :test_case_version => valid_attributes, format: :js}
        response.status.should eq(200)
      end
    end

    describe "for steward_id attribute" do
      it "should valid when the test case is locked for logged user" do
        sign_in user
        test_case.update(steward_id: user.id)

        expect do
          post :create, {project_id: project.id, test_case_id: test_case.id, test_case_version: valid_attributes}
        end.to change(Tmt::TestCaseVersion, :count).by(1)
      end

      it "should not valid when the test case is locked for other user" do
        sign_in user
        test_case.update(steward_id: 0)

        expect do
          post :create, {project_id: project.id, test_case_id: test_case.id, test_case_version: valid_attributes}
        end.to change(Tmt::TestCaseVersion, :count).by(0)
      end
    end

    describe "with invalid params" do
      [:js, :html].each do |format|
        it "assigns a newly created but unsaved test_case_version as @test_case_version for format #{format}" do
          sign_in user
          Tmt::TestCaseVersion.any_instance.stub(:save).and_return(false)
          post :create, {project_id: project.id, test_case_id: test_case.id, test_case_version: valid_attributes, format: format}
          assigns(:version).should be_a_new(Tmt::TestCaseVersion)
        end

        it "should show alert for format #{format}" do
          sign_in user
          Tmt::TestCaseVersion.any_instance.stub(:save).and_return(false)
          post :create, {project_id: project.id, test_case_id: test_case.id, :test_case_version => valid_attributes, format: format}
          flash[:alert].should eq('The comment is empty or did not attach file')
        end
      end

      it "re-renders the 'new' template" do
        sign_in user
        Tmt::TestCaseVersion.any_instance.stub(:save).and_return(false)
        post :create, {project_id: project.id, test_case_id: test_case.id, :test_case_version => valid_attributes}
        response.should redirect_to(project_test_case_path(project, test_case))
        response.status.should eq(302)
      end

      it "should have status 200 for format js" do
        sign_in user
        Tmt::TestCaseVersion.any_instance.stub(:save).and_return(false)
        post :create, {project_id: project.id, test_case_id: test_case.id, :test_case_version => valid_attributes, format: :js}
        response.status.should eq(200)
      end
    end
  end

  describe "GET download" do
    it_should_not_authorize(self, [:no_logged, :foreign]) do
      get :download, {project_id: project.id, test_case_id: test_case.id, id: version.to_param}
    end

    it "should properly download content of version" do
      sign_in user
      version = create(:test_case_version_with_revision, test_case: test_case)
      Tmt::TestCaseVersion.any_instance.stub(:content).and_return("Example content of file.")
      Tmt::TestCaseVersion.any_instance.stub(:file_name).and_return("file_name.seq")
      get :download, {project_id: project.id, test_case_id: test_case.id, id: version.to_param}
      response.body.should eq("Example content of file.")
      response.header["Content-Disposition"].should include("file_name.seq")
    end
  end

  describe "GET progress" do
    let(:version) { create(:test_case_version_with_revision, test_case: test_case) }

    before do
      ready(version)
    end

    it_should_not_authorize(self, [:no_logged, :foreign]) do
      get :progress, {project_id: project.id, test_case_id: test_case.id, id: version.to_param}
    end

    it "should redirect to previous page" do
      sign_in user
      request.env['HTTP_REFERER'] = root_path
      get :progress, {project_id: project.id, test_case_id: test_case.id, id: version.to_param, format: :html}
      response.should redirect_to(root_path)
    end

    it "should properly download content of version for format: js" do
      sign_in user
      get :progress, {project_id: project.id, test_case_id: test_case.id, id: version.to_param, format: :js}
      assigns(:version).should eq(version)
      assigns(:project).should eq(project)
      assigns(:test_case).should eq(test_case)
    end

  end
end
