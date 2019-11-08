require 'spec_helper'

describe Admin::ProjectsController do
  extend CanCanHelper

  let(:user) { create(:user) }

  let(:admin) { create(:admin) }

  let(:type) {create(:test_case_type, name: "default")}
  let(:valid_attributes) { { "name" => "MyString", creator_id: user.id } }

  let(:project) do
    project = create(:project, valid_attributes)
    project.add_member(user)
    project
  end

  let(:campaign) { create(:campaign, project: project) }

  let(:test_run) { create(:test_run, campaign: campaign) }

  let(:test_case) { create(:test_case, project: project) }

  describe "GET index" do
    it_should_not_authorize(self, [:no_logged, :foreign, 'self.user']) do
      ready(project)
      get :index
    end

    it "assigns all projects as @projects, logged user" do
      sign_in admin
      ready(project)
      get :index
      assigns(:projects).should eq([project])
    end

  end

  describe "GET new" do
    it_should_not_authorize(self, [:no_logged, :foreign, 'self.user']) do
      get :new
    end

    it "assigns a new project as @project" do
      sign_in admin
      get :new
      assigns(:project).should be_a_new(Tmt::Project)
    end

    it "assigns a test_case_types as @test_case_types" do
      sign_in admin
      Tmt::TestCaseType.delete_all
      type_deleted = create(:test_case_type, deleted_at: Time.now)
      type_undeleted = create(:test_case_type, deleted_at: nil)
      get :new
      assigns(:test_case_types).should match_array([type_undeleted])
    end
  end

  describe "GET edit" do
    it_should_not_authorize(self, [:no_logged, :foreign, 'self.user']) do
      get :edit, {id: project.to_param}
    end

    it "assigns the requested project as @project" do
      sign_in admin
      project = Tmt::Project.create! valid_attributes
      get :edit, {:id => project.to_param}
      assigns(:project).should eq(project)
    end

    it "assigns a test_case_types as @test_case_types" do
      sign_in admin
      Tmt::TestCaseType.delete_all
      type_deleted = create(:test_case_type, deleted_at: Time.now)
      type_undeleted = create(:test_case_type, deleted_at: nil)
      project = Tmt::Project.create! valid_attributes
      get :edit, {:id => project.to_param}
      assigns(:test_case_types).should match_array([type_undeleted])
    end

    it "assigns the requested project_name as @project_name" do
      sign_in admin

      project = Tmt::Project.create! valid_attributes
      get :edit, {:id => project.to_param}
      assigns(:project_name).should eq(project.name)
    end
  end

  describe "POST create" do
    describe "with valid params" do
      it_should_not_authorize(self, [:no_logged, :foreign, 'self.user']) do
        expect {
          post :create, {:project => valid_attributes}
        }.to change(Tmt::Project, :count).by(0)
      end

      it "creates a new Project when is logged admin" do
        sign_in admin

        expect {
          post :create, {:project => valid_attributes}
        }.to change(Tmt::Project, :count).by(1)
      end

      it "assigns a newly created project as @project" do
        sign_in admin
        post :create, {:project => valid_attributes}
        assigns(:project).should be_a(Tmt::Project)
        assigns(:project).should be_persisted
      end

      it "assigns a test_case_types as @test_case_types" do
        sign_in admin
        Tmt::TestCaseType.delete_all
        type_deleted = create(:test_case_type, deleted_at: Time.now)
        type_undeleted = create(:test_case_type, deleted_at: nil)
        post :create, {:project => valid_attributes}
        assigns(:test_case_types).should match_array([type_undeleted])
      end

      it "redirects to the created project" do
        sign_in admin
        post :create, {:project => valid_attributes}
        response.should redirect_to(admin_projects_path)
      end

    end

    describe "with invalid params" do
      before do
        sign_in admin
      end

      it "assigns a newly created but unsaved project as @project" do
        # Trigger the behavior that occurs when invalid params are submitted
        Tmt::Project.any_instance.stub(:save).and_return(false)
        post :create, {:project => { "name" => "invalid value" }}
        assigns(:project).should be_a_new(Tmt::Project)
      end

      it "re-renders the 'new' template" do
        # Trigger the behavior that occurs when invalid params are submitted
        Tmt::Project.any_instance.stub(:save).and_return(false)
        post :create, {:project => { "name" => "invalid value" }}
        response.should render_template("new")
      end
    end
  end

  describe "PUT update" do
    describe "with valid params" do
      it_should_not_authorize(self, [:no_logged, :foreign, 'self.user']) do
        project = Tmt::Project.create! valid_attributes
        put :update, {:id => project.to_param, :project => valid_attributes}
      end

      it "updates the requested project" do
        sign_in admin
        project = Tmt::Project.create! valid_attributes

        Tmt::Project.any_instance.should_receive(:update).with({ "name" => "MyString" })
        put :update, {:id => project.to_param, :project => { "name" => "MyString" }}
      end

      it "assigns the requested project as @project" do
        sign_in admin
        project = Tmt::Project.create! valid_attributes
        put :update, {:id => project.to_param, :project => valid_attributes}
        assigns(:project).should eq(project)
      end

      it "assigns a test_case_types as @test_case_types" do
        sign_in admin
        Tmt::TestCaseType.delete_all
        type_deleted = create(:test_case_type, deleted_at: Time.now)
        type_undeleted = create(:test_case_type, deleted_at: nil)
        project = Tmt::Project.create! valid_attributes
        put :update, {:id => project.to_param, :project => valid_attributes}
        assigns(:test_case_types).should match_array([type_undeleted])
      end

      it "redirects to the project" do
        sign_in admin
        project = Tmt::Project.create! valid_attributes
        put :update, {:id => project.to_param, :project => valid_attributes}
        response.should redirect_to(admin_projects_path)
      end

    end

    describe "with invalid params" do

      it "assigns the project as @project" do
        sign_in admin
        project = Tmt::Project.create! valid_attributes
        # Trigger the behavior that occurs when invalid params are submitted
        Tmt::Project.any_instance.stub(:save).and_return(false)
        put :update, {:id => project.to_param, :project => { "name" => "invalid value" }}
        assigns(:project).should eq(project)
      end

      it "re-renders the 'edit' template" do
        sign_in admin

        project = Tmt::Project.create! valid_attributes
        Tmt::Project.any_instance.stub(:save).and_return(false)
        put :update, {:id => project.to_param, :project => { "name" => "invalid value" }}
        response.should render_template("edit")
      end
    end
  end

end
