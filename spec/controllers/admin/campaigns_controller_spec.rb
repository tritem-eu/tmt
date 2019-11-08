require 'spec_helper'

describe Admin::CampaignsController do
  extend CanCanHelper

  let(:valid_attributes) { { "name" => "MyString", project_id: active_project.id } }

  let(:campaign) { Tmt::Campaign.create! valid_attributes }

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

  describe "GET index" do
    before do
      ready(campaign)
    end

    it_should_not_authorize(self, [:no_logged, :foreign]) do
      get :index
    end

    it "doesn't assign campaigns as @campaigns when user doesn't define project_id" do
      sign_in admin
      get :index
      response.should render_template("index")
      assigns(:campaigns).should include(campaign)
    end

    it "assigns campaigns as @campaigns when user define project_id" do
      sign_in admin
      get :index, {project_id: active_project.id}
      assigns(:campaigns).should eq([campaign])
    end

    it "assigns projects as @projects" do
      sign_in admin
      [project, active_project]
      get :index
      assigns(:projects).should include(project)
      assigns(:projects).should include(active_project)
    end

    it "assigns amount test runs per campaign as @amount_test_runs_per_campaign" do
      sign_in admin
      first_test_run = campaign.test_runs.create(name: 'Example name', creator: admin)
      second_test_run = campaign.test_runs.create(name: 'Example name', creator: admin, deleted_at: Time.now)
      get :index
      assigns(:amount_test_runs_per_campaign).should include(campaign => 1)
    end

    it "assigns close campaigns" do
      sign_in admin
      ready active_project
      campaign = active_project.open_campaign
      campaign.is_open = false
      campaign.save(validate: false)
      get :index
      assigns(:projects).should include(active_project)
      campaign.reload.is_open.should be false
    end
  end

  describe "GET new" do
    it_should_not_authorize(self, [:no_logged, :foreign]) do
      ready(project)
      get :new, {:project_id => project.id}
    end

    [:html, :js].each do |format|
      it "assigns the requested campaign as @campaign for format #{format}" do
        sign_in admin
        ready(project)
        get :new, {:project_id => project.id, format: format}
        assigns(:campaign).attributes.should eq(::Tmt::Campaign.new(project: project).attributes)
      end
    end

    it "assigns the requested campaign as @campaign for format js" do
      sign_in admin
      ready(campaign)
      get :edit, {:id => campaign.to_param, format: :js}
      assigns(:campaign).should eq(campaign)
    end
  end

  describe "GET edit" do
    it_should_not_authorize(self, [:no_logged, :foreign]) do
      campaign = Tmt::Campaign.create! valid_attributes
      get :edit, {:id => campaign.to_param}
    end

    [:html, :js].each do |format|
      it "assigns the requested campaign as @campaign for format #{format}" do
        sign_in admin
        campaign = Tmt::Campaign.create! valid_attributes
        get :edit, :id => campaign.to_param, format: format
        assigns(:campaign).should eq(campaign)
      end
    end
  end

  describe "POST create" do
    describe "with valid params" do
      it_should_not_authorize(self, [:no_logged, :foreign]) do
        campaign = Tmt::Campaign.create! valid_attributes
        post :create, {:campaign => valid_attributes}
      end

      [:html, :js].each do |format|
        it "creates a new Campaign for format #{format}" do
          sign_in admin
          expect {
            post :create, :campaign => valid_attributes, format: format
          }.to change(Tmt::Campaign, :count).by(1)
        end

        it "assigns a newly created campaign as @campaign for format #{format}" do
          sign_in admin
          post :create, :campaign => valid_attributes, format: format
          assigns(:campaign).should be_a(Tmt::Campaign)
          assigns(:campaign).should be_persisted
        end
      end

      it "redirects to the created campaign" do
        sign_in admin
        post :create, :campaign => valid_attributes
        response.should redirect_to(admin_campaigns_path(project_id: active_project.id))
      end

    end

    describe "with invalid params" do
      [:html, :js].each do |format|
        it "assigns a newly created but unsaved campaign as @campaign for format #{format}" do
          sign_in admin
          # Trigger the behavior that occurs when invalid params are submitted
          Tmt::Campaign.any_instance.stub(:save).and_return(false)
          post :create, :campaign => { "name" => "invalid value" }, format: format
          assigns(:campaign).should be_a_new(Tmt::Campaign)
        end
      end

      it "re-renders the 'new' template" do
        sign_in admin
        # Trigger the behavior that occurs when invalid params are submitted
        Tmt::Campaign.any_instance.stub(:save).and_return(false)
        post :create, :campaign => { "name" => "invalid value" }
        response.should render_template("index")
      end
    end
  end

  describe "PUT update" do
    describe "with valid params" do
      it_should_not_authorize(self, [:no_logged, :foreign]) do
        campaign = Tmt::Campaign.create! valid_attributes
        put :update, {:id => campaign.to_param, :campaign => { "name" => "MyString" }}
      end

      [:html, :js].each do |format|
        it "updates the requested campaign for format #{format}" do
          sign_in admin
          campaign = Tmt::Campaign.create! valid_attributes
          Tmt::Campaign.any_instance.should_receive(:update).with({ "name" => "MyString" })
          put :update, :id => campaign.to_param, :campaign => { "name" => "MyString" }, format: format
        end

        it "assigns the requested campaign as @campaign for format #{format}" do
          sign_in admin
          campaign = Tmt::Campaign.create! valid_attributes
          put :update, :id => campaign.to_param, :campaign => valid_attributes, format: format
          assigns(:campaign).should eq(campaign)
        end
      end

      it "redirects to the campaign" do
        sign_in admin
        campaign = Tmt::Campaign.create! valid_attributes
        project = campaign.project
        put :update, :id => campaign.to_param, :campaign => valid_attributes
        response.should redirect_to(admin_campaigns_path(project_id: project.id))
      end
    end

    describe "with invalid params" do

      it "assigns the campaign as @campaign" do
        sign_in admin
        campaign = Tmt::Campaign.create! valid_attributes
        # Trigger the behavior that occurs when invalid params are submitted
        Tmt::Campaign.any_instance.stub(:save).and_return(false)
        put :update, {:id => campaign.to_param, :campaign => { "name" => "invalid value" }}
        assigns(:campaign).should eq(campaign)
      end

      it "re-renders the 'edit' template" do
        sign_in admin
        campaign = Tmt::Campaign.create! valid_attributes
        # Trigger the behavior that occurs when invalid params are submitted
        Tmt::Campaign.any_instance.stub(:save).and_return(false)
        put :update, {:id => campaign.to_param, :campaign => { "name" => "invalid value" }}
        response.should render_template("edit")
      end
    end
  end

  describe "GET close" do
    before do
      ready(campaign)
    end

    it "Nobody cannot close the project" do
      campaign.is_open.should be true
      get :close, {id: campaign.id}
      campaign.reload.is_open.should be true
    end

    it "User cannot close the project" do
      sign_in campaign.project.users.first
      campaign.is_open.should be true
      get :close, {id: campaign.id}
      campaign.reload.is_open.should be true
    end

    it "Admin can close the campaign which has got an empty collection of test_runs" do
      sign_in admin
      campaign.is_open.should be true
      campaign.test_runs = []
      get :close, {id: campaign.id}
      campaign.reload.is_open.should be false
    end

    it "Admin can close the campaign when all test_runs are closed" do
      sign_in admin
      campaign.is_open.should be true
      campaign.test_runs << create(:test_run, campaign: campaign)
      campaign.test_runs.update_all(status: 4)
      get :close, {id: campaign.id}
      campaign.reload.is_open.should be false
    end

    it "Admin can close the campaign when test_run is deleted" do
      sign_in admin
      campaign.is_open.should be true
      campaign.test_runs << create(:test_run, campaign: campaign, deleted_at: Time.now)
      campaign.test_runs.first.has_status?(:new).should be true
      get :close, {id: campaign.id}
      campaign.reload.is_open.should be false
      flash[:notice].should match(/Campaign was successfully closed/)
    end

    it "Admin cannot close the campaign when at least one test_run is not closed" do
      sign_in admin
      campaign.is_open.should be true
      campaign.test_runs << create(:test_run, campaign: campaign)
      campaign.test_runs << create(:test_run, campaign: campaign)
      campaign.test_runs.last.update(status: 4)
      get :close, {id: campaign.id}
      campaign.reload.is_open.should be true
      flash[:alert].should match(/Campaign cannot be closed because at least one test run is active/)
    end

    it "Admin cannot close the campaign when at least one test_run has status executing" do
      sign_in admin
      campaign.is_open.should be true
      test_run = create(:test_run, campaign: campaign, executor: user)
      create(:execution, test_run: test_run)
      test_run.set_status_planned
      test_run.set_status_executing
      test_run.reload.has_status?(:executing).should be true
      get :close, {id: campaign.id}
      campaign.reload.is_open.should be true
      flash[:alert].should match(/Campaign cannot be closed because at least one test run is active/)
    end

  end
end
