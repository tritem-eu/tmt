require 'spec_helper'

describe Tmt::TestCasesSetsController do
  extend CanCanHelper

  let(:project) { create(:project) }
  let(:set) { create(:set, project: project) }
  let(:test_case) { create(:test_case, project: project)}
  let(:test_cases_set) { Tmt::TestCasesSets.create(set: set, test_case: test_case) }
  let(:user) do
    user = create(:user)
    project.add_member(user)
    user
  end

  let(:test_case) { create(:test_case, project: project) }

  describe "GET new" do
    before do
      ready(project, set, test_case)
    end

    it_should_not_authorize(self, [:no_logged, :foreign]) do
      get :new, {project_id: project.id, set_id: set.id}
    end

    it "assigns project as @project" do
      sign_in user
      get :new, {project_id: project.id, set_id: set.id}
      assigns(:project).should eq(project)
    end

    it "assigns test_cases as @test_cases" do
      sign_in user
      get :new, {project_id: project.id, set_id: set.id}
      assigns(:test_cases).should include(test_case)
    end

    it "assigns set as @set" do
      sign_in user
      get :new, {project_id: project.id, set_id: set.id}
      assigns(:set).should eq(set)
    end

    it "assigns test_cases_set as @test_cases_set" do
      sign_in user
      get :new, {project_id: project.id, set_id: set.id}
      assigns(:test_cases_set).should be_a(Tmt::TestCasesSets)
    end

  end

  describe "POST create" do
    before do
      ready(project, set)
    end

    it "creates a new Tmt::TestCasesSets" do
      sign_in user
      expect do
        post :create, {project_id: project.id, set_id: set.id, test_case_id: test_case.id}
      end.to change(Tmt::TestCasesSets, :count).by(1)
    end

    it "doesn't create a new Tmt::TestCasesSets when test_case_id is nil" do
      sign_in user
      expect do
        post :create, {project_id: project.id, set_id: set.id}
      end.to change(Tmt::TestCasesSets, :count).by(0)
    end

    it "doesn't create a new Tmt::TestCasesSets when set_id is nil" do
      sign_in user
      expect do
        post :create, {project_id: project.id, test_case_id: test_case.id}
      end.to change(Tmt::TestCasesSets, :count).by(0)
    end

    it "assigns project as @project" do
      sign_in user
      post :create, {project_id: project.id, set_id: set.id}
      assigns(:project).should eq(set.project)
    end

    it_should_not_authorize(self, [:no_logged, :foreign]) do
      post :create, {project_id: project.id, set_id: set.id, test_case_id: test_case.id}
    end

    it "redirects to the board of sets" do
      sign_in user
      post :create, {project_id: project.id, set_id: set.id, test_case_id: test_case.id}
      response.should redirect_to project_sets_path(project)
    end
  end

  describe "DELETE destroy" do
    before do
      ready(project)
      ready(test_cases_set)
    end

    it "destroyes test_cases_set" do
      sign_in user
      expect do
        delete :destroy, {project_id: project.id, id: test_cases_set.id}
      end.to change(Tmt::TestCasesSets, :count).by(-1)
    end

    it "destroyes test_cases_set for format js" do
      sign_in user
      expect do
        delete :destroy, {project_id: project.id, id: test_cases_set.id, format: :js}
      end.to change(Tmt::TestCasesSets, :count).by(-1)
    end

    it "should redirect to sets view for format js" do
      sign_in user
      delete :destroy, {project_id: project.id, id: test_cases_set.id, format: :js}
      response.body.should eq "window.location.href='#{project_sets_url(project)}'"
    end

    it "should redirect to sets view" do
      sign_in user
      delete :destroy, {project_id: project.id, id: test_cases_set.id}
      response.should redirect_to(project_sets_url(project))
    end

    it "should show alert" do
      sign_in user
      delete :destroy, {project_id: project.id, id: test_cases_set.id}
      flash[:notice].should eq('Deleted record')
    end

    it "should show alert for format js" do
      sign_in user
      delete :destroy, {project_id: project.id, id: test_cases_set.id, format: :js}
      flash[:notice].should eq('Deleted record')
    end

    it_should_not_authorize(self, [:no_logged, :foreign]) do
      delete :destroy, {project_id: project.id, id: test_cases_set.id}
    end

  end
end
