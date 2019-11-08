require 'spec_helper'

describe Tmt::CampaignsController do
  extend CanCanHelper

  let(:campaign) { Tmt::Campaign.create!({name: "ver0.1.0", project_id: active_project.id}) }

  let(:user) { create(:user) }

  let(:admin) { create(:admin) }

  let(:active_project) do
    project = create(:project)
    project.add_member(user)
    project
  end

  let(:project) do
    project = create(:project)
    project.add_member(user)
    project
  end

  let(:test_run) { create(:test_run, campaign: campaign) }

  describe "GET show" do
    it_should_not_authorize(self, [:no_logged, :foreign]) do
      ready(campaign)
      get :show, {project_id: active_project.id, id: campaign.to_param}
    end

    it "should authorize for member of campaign" do
      sign_in user
      ready(campaign)
      get :show, :id => campaign.to_param, project_id: active_project.id
      response.code.should eq("200")
    end

    [:html, :js].each do |format|
      it "assigns the requested campaign as @campaign for format #{format}" do
        sign_in admin
        ready(campaign)
        get :show, :id => campaign.to_param, project_id: active_project.id, format: format
        assigns(:campaign).should eq(campaign)
      end

      it "assigns the requested project of campaign for format #{format}" do
        sign_in admin
        ready(campaign)
        get :show, id: campaign.to_param, project_id: active_project.id, format: format
        assigns(:project).should eq(campaign.project)
      end

      it "assigns the requested test runs of campaign for format #{format}" do
        sign_in admin
        ready(campaign)
        first_test_run = campaign.test_runs.create(name: 'Example name', creator: admin)
        second_test_run = campaign.test_runs.create(name: 'Example name', creator: admin, deleted_at: Time.now)
        get :show, id: campaign.to_param, project_id: active_project.id, format: format
        assigns(:test_runs).should include(first_test_run)
        assigns(:test_runs).should_not include(second_test_run)
      end
    end
  end
end
