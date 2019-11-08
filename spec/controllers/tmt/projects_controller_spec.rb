require 'spec_helper'

describe Tmt::ProjectsController do
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

  describe "GET show" do
    before do
      ready(project)
    end

    it_should_not_authorize(self, [:no_logged, :foreign]) do
      get :show, {:id => project.to_param}
    end

    it "assigns the requested project as @project" do
      sign_in create(:user)
      get :show, {:id => project.to_param}
      assigns(:project).should eq(project)
    end

    it "assigns all test_cases as @test_cases" do
      sign_in user
      test_case_undeleted = create(:test_case, project: project, creator: user)
      test_case_deleted = create(:test_case, project: project, creator: user, deleted_at: Time.now)

      get :show, {id: project.to_param}
      assigns(:test_cases).should match_array([test_case_undeleted])
    end

    it "assigns all test_runs as @test_runs" do
      sign_in user
      campaign = create(:campaign, project: project)
      test_run_undeleted = create(:test_run, campaign: campaign, creator: user)
      test_run_deleted = create(:test_run, deleted_at: Time.now, campaign: campaign, creator: user)
      get :show, {id: project.to_param}
      assigns(:test_runs).should match_array([test_run_undeleted])
    end

    it "assigns group of test runs as @test_run_graph" do
      sign_in user
      campaign = create(:campaign, project: project)
      time = Time.now
      Time.stub(:now) {time}
      test_run = create(:test_run, campaign: campaign, creator: user, status: 4)
      get :show, {id: project.to_param}
      assigns(:test_run_graph).should include(time.strftime('%Y-%m-%d') => 1)
    end

    it "assigns group of test cases as @test_case_graph" do
      sign_in user
      time = Time.now
      Time.stub(:now) {time}
      test_run = create(:test_case, project: project, creator: user)
      get :show, {id: project.to_param}
      assigns(:test_case_graph).should include(time.strftime('%Y-%m-%d') => 1)
    end

    it "assigns all campaigns as @campaigns" do
      sign_in user
      ready(campaign)
      get :show, {id: project.to_param}
      assigns(:campaign).should eq(campaign)
    end

    it "saves current project in current user entry" do
      sign_in user
      ready(project)
      user.reload.current_project.should be_nil
      get :show, {id: project.id}
      user.reload.current_project.should eq(project)
    end

    it "render show with test_runs" do
      sign_in user
      ready(campaign, test_run)
      test_run.update(status: 4)
      get :show, {id: project.to_param}
      request.should render_template('show')
    end

    it "render show with test_cases" do
      sign_in user
      ready(campaign, test_case)
      test_case.update(name: "New name of test case")
      get :show, {id: project.to_param}
      request.should render_template('show')
    end

  end

end
