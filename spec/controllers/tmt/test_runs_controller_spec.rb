require 'spec_helper'
describe Tmt::TestRunsController do
  extend CanCanHelper

  let(:creator) { create(:user) }
  let(:admin) { create(:admin) }
  let(:user) do
    user = create(:user)
    project.add_member(user)
    user
  end

  let(:executor) do
    user = create(:user)
    project.add_member(user)
    user
  end

  let(:project) { create(:project, creator: creator) }
  let(:project_next) { create(:project, creator: creator) }

  let(:campaign_old) do
    campaign = create(:campaign, is_open: false, project: project)
    campaign.close
    campaign
  end

  let(:campaign) do
    campaign_old
    create(:campaign, project: project)
  end

  let(:campaign_foreign) { create(:campaign, project: project_next) }

  let(:valid_attributes) do
    {
      creator_id: creator.id,
      campaign_id: campaign.id,
      name: "Name",
      executor_id: executor.id
    }
  end

  let(:test_run) do
    test_run = create(:test_run, valid_attributes)
    test_run.versions << create(:test_case_version_with_revision)
    test_run.versions << create(:test_case_version_with_revision)
    test_run
  end

  let(:test_run_campaign_old) { create(:test_run, campaign_id: campaign_old.id) }
  let(:test_run_campaign_foreign) { create(:test_run, campaign_id: campaign_foreign.id) }

  let(:custom_fields) do
    {
      string: create(:test_run_custom_field, type_name: :string, project_id: project.id, name: 'Name'),
      text: create(:test_run_custom_field_for_text, project_id: project.id, name: 'description'),
      date: create(:test_run_custom_field_for_date, project_id: project.id, name: 'Deadline'),
      int: create(:test_run_custom_field_for_integer, project_id: project.id, name: 'Amount'),
      bool: create(:test_case_custom_field_for_bool, project_id: project.id, name: 'isActive'),
      bool2: create(:test_case_custom_field_for_bool, project_id: project.id, name: 'isOfficial'),
      enum: create(:test_run_custom_field_for_enumeration, project_id: project.id, name: 'Priorities')
    }
  end

  describe "GET index" do
    before do
      ready(test_run, test_run_campaign_old, test_run_campaign_foreign)
    end

    it_should_not_authorize(self, [:no_logged, :foreign]) do
      get :index, {project_id: project.id, campaign_id: campaign.id}
    end

    context "assigns all test_runs as @test_runs for" do
      it "current campaign" do
        sign_in user
        get :index, {project_id: project.id,  campaign_ids: [campaign.id.to_s]}
        assigns(:test_runs).should eq([test_run])
      end

      it "current project" do
        sign_in user
        test_run_campaign_foreign.should_not be_nil
        get :index, {project_id: project.id}
        assigns(:test_runs).should match_array([test_run, test_run_campaign_old])
      end

      it "without open campaign" do
        sign_in user
        test_run_campaign_foreign.should_not be_nil
        get :index, {project_id: project.id}
        assigns(:test_runs).should match_array([test_run, test_run_campaign_old])
      end

      it "render view when a database has not campaings and test_runs for specific project" do
        sign_in user
        Tmt::TestRun.delete_all
        Tmt::Campaign.delete_all
        create(:test_run)
        create(:test_run)
        get :index, {project_id: project.id}
        assigns(:test_runs).should be_empty
      end
    end

  end

  describe "GET clone" do
    before do
      ready(test_run, project)
    end

    it_should_not_authorize(self, [:no_logged, :foreign]) do
      get :clone, project_id: project.id, id: test_run.id
    end

    it "should clone test run" do
      sign_in user
      test_run.creator.should_not eq(user)
      expect do
        get :clone, project_id: project.id, id: test_run.id
      end.to change(Tmt::TestRun, :count).by(1)
      Tmt::TestRun.last.creator.should eq(user)
    end

    it "redirect to view cloned test run" do
      sign_in user
      get :clone, project_id: project.id, id: test_run.id
      cloned_test_run = Tmt::TestRun.last
      response.should redirect_to(project_test_run_path(project, cloned_test_run))
    end

    it "shows flash information" do
      sign_in user
      get :clone, project_id: project.id, id: test_run.id
      flash[:notice].should match(/Test Run was successfully cloned/)
    end
  end

  describe "GET terminate" do

    before do
      ready(test_run, project)
      test_run.set_status_planned
    end

    it_should_not_authorize(self, [:no_logged, :foreign, 'self.user']) do
      get :terminate, project_id: project.id, id: test_run.id
    end

    it "redirect to test run" do
      sign_in admin
      get :terminate, project_id: project.id, id: test_run.id
      response.should redirect_to(project_test_run_path(project, test_run))
    end

    it "shows flash information" do
      sign_in admin
      get :terminate, project_id: project.id, id: test_run.id
      flash[:notice].should match(/Test run was successfully terminated/)
    end

    it "should set status of test run on 'done'" do
      sign_in admin
      get :terminate, project_id: project.id, id: test_run.id
      test_run.reload.has_status?(:done).should be true
    end
  end

  describe "GET calendar" do
    before do
      ready(test_run, test_run_campaign_old, test_run_campaign_foreign)
    end

    it_should_not_authorize(self, [:no_logged, :foreign]) do
      get :calendar, {project_id: project.id, campaign_id: campaign.id}
    end

    it "assigns all test_runs and real year and month for calendar" do
      sign_in user

      test_run.update(due_date: Date.new(2000, 2, 3))
      time = Time.now
      Time.stub(:now) { time }
      get :calendar, {project_id: project.id, campaign_id: campaign.id}
      assigns(:year).should eq(time.year)
      assigns(:month).should eq(time.month)
    end

    it "assigns all test_runs and year and month which was fixed for calendar" do
      sign_in user

      test_run.update(due_date: Date.new(2000, 2, 3))
      get :calendar, {project_id: project.id, campaign_id: campaign.id, date: {year: 2000, month: 2}}
      assigns(:year).should eq(2000)
      assigns(:month).should eq(2)
    end

    it "assigns test_runs which was fixed for calendar" do
      sign_in user
      ready(test_run_campaign_old)
      Tmt::TestRun.skip_callback(:save, :before, :set_due_date_with_current_time)
      test_run.update(due_date: Date.new(2000, 2, 3))
      get :calendar, {project_id: project.id, campaign_id: campaign.id, date: {year: 2000, month: 2}}
      assigns(:test_runs).should match_array([test_run])
    end

    it "assigns test_runs which was fixed for calendar without pagination" do
      sign_in user
      ready(test_run_campaign_old)
      Tmt::TestRun.skip_callback(:save, :before, :set_due_date_with_current_time)
      test_run.update(due_date: Date.new(2000, 2, 3))
      get :calendar, {project_id: project.id, campaign_id: campaign.id, page: 100000, date: {year: 2000, month: 2}}
      assigns(:test_runs).should match_array([test_run])
    end

  end

  describe "GET calendar_day" do
    before do
      ready(test_run, test_run_campaign_old, test_run_campaign_foreign)
    end

    it_should_not_authorize(self, [:no_logged, :foreign]) do
      get :calendar_day, {project_id: project.id, year: 2014, month: 5, day: 3}
    end

    it "assigns year which was fixed for calendar" do
      sign_in user
      test_run.update(due_date: Date.new(1999, 4, 9))
      get :calendar_day, {project_id: project.id, year: 1999, month: 4, day: 9}
      assigns(:year).should eq(1999)
    end

    it "assigns month which was fixed for calendar" do
      sign_in user
      test_run.update(due_date: Date.new(1999, 4, 9))
      get :calendar_day, {project_id: project.id, year: 1999, month: 4, day: 9}
      assigns(:month).should eq(4)
    end

    it "assigns all test_runs which was fixed for calendar" do
      sign_in user
      Time.zone = 'UTC'
      Tmt::TestRun.skip_callback(:save, :before, :set_due_date_with_current_time)
      test_run.update(due_date: Date.new(1999, 4, 9))
      get :calendar_day, {project_id: project.id, year: 1999, month: 4, day: 9}
      assigns(:test_runs).should match_array([test_run])
    end

    it "assigns day which was fixed for calendar" do
      sign_in user
      Time.zone = 'UTC'

      test_run.update(due_date: Date.new(1999, 4, 9))
      get :calendar_day, {project_id: project.id, year: 1999, month: 4, day: 9}
      assigns(:day).should eq(9)
    end

  end

  describe "GET show" do

    it_should_not_authorize(self, [:no_logged, :foreign]) do
      get :show, {project_id: project.id, campaign_id: campaign.id, id: test_run.id}
    end

    it "saves current test run to member" do
      sign_in user
      ready(test_run)
      member = Tmt::Member.where(user: user, project: project).first
      member.current_test_run.should be_nil
      get :show, {project_id: project.id, campaign_id: campaign.id, id: test_run.id}
      member.reload.current_test_run.should eq(test_run)
    end

    it "render template show" do
      sign_in user
      ready(test_run)
      get :show, {project_id: project.id, campaign_id: campaign.id, id: test_run.id}
      response.should render_template('show')
    end

    it "assigns the requested test_run as @test_run" do
      sign_in user
      ready(test_run)
      get :show, {project_id: project.id, campaign_id: campaign.id, id: test_run.id}
      assigns(:test_run).should eq(test_run)
    end

    describe 'should render view of test run' do
      before do
        sign_in user
        ready(test_run)
        create(:execution, test_run: test_run)
        test_run.update(due_date: Time.now)
      end
=begin
      it "with status new" do
        ready(test_run)
        test_run.has_status?(:new)
        rendered_view? do
          get :show, {project_id: project.id, campaign_id: campaign.id, :id => test_run.to_param}
        end
      end

      it "with status planned" do
        test_run.set_status_planned
        test_run.reload.has_status?(:planned)
        test_run.versions.should_not be_empty

        rendered_view? do
          get :show, {project_id: project.id, campaign_id: campaign.id, :id => test_run.to_param}
        end
      end

      it "with status executing" do
        test_run.set_status_planned
        test_run.set_status_executing
        test_run.reload.has_status?(:executing)
        test_run.versions.should_not be_empty

        rendered_view? do
          get :show, {project_id: project.id, campaign_id: campaign.id, :id => test_run.to_param}
        end
      end

      it "with status done" do
        test_run.set_status_planned
        test_run.set_status_executing
        test_run.executions.update_all(status: :passed, comment: 'comment')
        test_run.update_status
        test_run.reload.has_status?(:done)
        test_run.versions.should_not be_empty

        rendered_view? do
          get :show, {project_id: project.id, campaign_id: campaign.id, :id => test_run.to_param}
        end
      end
=end
      it "should show order the list of versions by created_at attribute and select current version of test case" do
        test_case = create(:test_case, project: project)
        first_version = create(:test_case_version, test_case: test_case)
        second_version = create(:test_case_version_with_revision, test_case: test_case)

        create(:execution, test_run: test_run, version: first_version)
        create(:execution, test_run: test_run, version: second_version)
        get :show, {project_id: project.id, campaign_id: campaign.id, :id => test_run.to_param}
        trs = Nokogiri.parse(response.body).css('.test-run-with-test-cases > tbody > tr')
        trs[0].css('td')[1].to_s.should include("href=\"/projects/#{project.id}/test-cases/#{test_case.id}/versions/#{second_version.id}\">#{second_version.id} <span class=\"glyphicon glyphicon-leaf \" style=\"font-size: 10px; color: #789abc\"></span></a>")
        trs[1].css('td')[1].to_s.should include("href=\"/projects/#{project.id}/test-cases/#{test_case.id}/versions/#{first_version.id}\">#{first_version.id}</a>")
      end
    end
  end

  describe "GET new" do
    it_should_not_authorize(self, [:no_logged, :foreign]) do
      get :new, {project_id: project.id, campaign_id: campaign.id }
    end

    it "should render new template when user is logged" do
      sign_in user
      get :new, {project_id: project.id, campaign_id: campaign.id }
      response.should render_template('new')
    end

    it "assigns a new test_run as @test_run" do
      sign_in user
      get :new, {project_id: project.id, campaign_id: campaign.id}
      assigns(:test_run).should be_a_new(Tmt::TestRun)
    end
  end

  describe "GET edit" do
    it_should_not_authorize(self, [:no_logged, :foreign]) do
      test_run = Tmt::TestRun.create! valid_attributes
      get :edit, {project_id: project.id, campaign_id: campaign.id, :id => test_run.to_param}
    end

    it "assigns the requested test_run as @test_run" do
      sign_in user
      test_run = Tmt::TestRun.create! valid_attributes
      get :edit, {project_id: project.id, campaign_id: campaign.id, :id => test_run.to_param}
      assigns(:test_run).should eq(test_run)
    end
  end

  describe "POST create" do
    describe "with valid params" do
      it_should_not_authorize(self, [:no_logged, :foreign]) do
        expect {
          post :create, {project_id: project.id, campaign_id: campaign.id, test_run: valid_attributes}
        }.to change(Tmt::TestRun, :count).by(0)
      end

      it "creates a new TestRun" do
        sign_in user
        expect {
          post :create, {project_id: project.id, campaign_id: campaign.id, test_run: valid_attributes}
        }.to change(Tmt::TestRun, :count).by(1)
      end

      it "doesn't create the test_run when campaign is closed" do
        sign_in user
        campaign.close
        expect {
          post :create, {project_id: project.id, campaign_id: campaign.id, test_run: valid_attributes}
        }.to change(Tmt::TestRun, :count).by(0)
      end

      it "assigns a newly created test_run" do
        sign_in user
        post :create, {project_id: project.id, campaign_id: campaign.id, test_run: valid_attributes}
        assigns(:test_run).should be_a(Tmt::TestRun)
        assigns(:test_run).should be_persisted
      end

      it "redirects to the created test_run" do
        sign_in user
        post :create, {project_id: project.id, campaign_id: campaign.id, test_run: valid_attributes}
        response.should redirect_to(project_campaign_test_run_path(project, campaign, Tmt::TestRun.last))
      end

    end

    describe "with invalid params" do
      it_should_not_authorize(self, [:no_logged, :foreign]) do
        Tmt::TestRun.any_instance.stub(:save).and_return(false)
        post :create, {project_id: project.id, campaign_id: campaign.id, test_run: { "creator_id" => "invalid value" }}
      end

    end

    describe "with valid params and custom fields"  do
      let(:valid_attributes_with_custom_fields) do
        valid_attributes.merge({
          custom_field_values: {
            custom_fields[:string].id.to_s => {value: "Example"},
            custom_fields[:text].id.to_s => {value: "description of Example"},
            custom_fields[:date].id.to_s => {value: '2014-02-20'},
            custom_fields[:int].id.to_s => {value: 93},
            custom_fields[:enum].id.to_s => {
              value: custom_fields[:enum].enumeration.values.last.numerical_value
            }
          }
        })
      end

      {
        string: 'Example',
        text: 'description of Example',
        date: '2014-02-20',
        int: 93,
        enum: 'high'
      }.each do |key, value|
        it "for #{key} type" do
          ready(valid_attributes_with_custom_fields)
          sign_in user
          expect {
            post :create, {project_id: project.id, campaign_id: campaign.id, test_run: valid_attributes_with_custom_fields}
          }.to change(Tmt::TestRun, :count).by(1)
          custom_field_value = ::Tmt::TestRun.last.custom_field_values.where(custom_field: custom_fields[key]).first
          custom_field_value.value.should eq(value)
        end
      end

    end
  end

  describe "PUT update" do
    describe "with valid params" do
      it "updates the requested test_run" do
        sign_in user

        ready(test_run)
        Tmt::TestRun.any_instance.should_receive(:update).with({ "name" => "New name" })
        put :update, {project_id: project.id, campaign_id: campaign.id, id: test_run.to_param, :test_run => { name: "New name" }}
      end

      it_should_not_authorize(self, [:no_logged, :foreign]) do
        ready(test_run)
        put :update, {project_id: project.id, campaign_id: campaign.id, id: test_run.to_param, :test_run => { name: "New name" }}
      end

      it "should authorize when test case is deleted" do
        sign_in user
        test_run.update(deleted_at: Time.now)
        put :update, {project_id: project.id, campaign_id: campaign.id, id: test_run.to_param, :test_run => { name: "Example updated name" }}
        flash[:alert].should eq('You are not authorized to access this page.')
        test_run.reload.name.should_not eq('Example updated name')
      end

      it "assigns the requested test_run as @test_run" do
        sign_in user

        ready(test_run)
        put :update, {project_id: project.id, campaign_id: campaign.id, id: test_run.to_param, :test_run => valid_attributes}
        assigns(:test_run).should eq(test_run)
      end

      it "redirects to the test_run" do
        sign_in user

        test_run = Tmt::TestRun.create! valid_attributes
        put :update, {project_id: project.id, campaign_id: campaign.id, id: test_run.to_param, :test_run => valid_attributes}
        response.should redirect_to(project_campaign_test_run_path(project, campaign, test_run))
      end

      it "doesn't update the test_run when campaign is closed" do
        sign_in user
        ready(test_run)
        put :update, {project_id: project.id, campaign_id: campaign.id, id: test_run.to_param, :test_run => {name: 'new name of test run'}}
        test_run.reload
        test_run.name.should include('new name of test run')
        campaign.close
        put :update, {project_id: project.id, campaign_id: campaign.id, id: test_run.to_param, :test_run => {name: 'new name of test run Bis'}}
        test_run.reload
        test_run.name.should_not include('new name of test run Bis')
      end

      it "doesn't update the test_run when status is 'done' or 'error'" do
        sign_in user
        ready(test_run)
        put :update, {project_id: project.id, campaign_id: campaign.id, id: test_run.to_param, :test_run => {name: 'new name of test run'}}
        test_run.reload
        test_run.name.should include('new name of test run')
        test_run.update(status: 4)
        put :update, {project_id: project.id, campaign_id: campaign.id, id: test_run.to_param, :test_run => {name: 'new name of test run Bis'}}
        test_run.reload
        test_run.name.should_not include('new name of test run Bis')
      end

    end

    describe "with invalid params" do
      before do
        ready(campaign)
      end

      it "assigns the test_run as @test_run" do
        sign_in user

        test_run = Tmt::TestRun.create! valid_attributes
        # Trigger the behavior that occurs when invalid params are submitted
        Tmt::TestRun.any_instance.stub(:save).and_return(false)
        put :update, {project_id: project.id, campaign_id: campaign.id, :id => test_run.to_param, :test_run => { "creator_id" => "" }}
        assigns(:test_run).should eq(test_run)
      end

      it "re-renders the 'edit' template" do
        sign_in user
        ready(test_run)
        Tmt::TestRun.any_instance.stub(:save).and_return(false)
        put :update, {project_id: project.id, campaign_id: campaign.id, id: test_run.to_param, test_run: { "creator_id" => "" }}
        response.should render_template("edit")
      end
    end

    describe "with valid params and custom fields"  do
      let(:valid_attributes_with_custom_fields) do
        valid_attributes.merge({
          custom_field_values: {
            custom_fields[:string].id.to_s => {value: "Example"},
            custom_fields[:text].id.to_s => {value: "description of Example"},
            custom_fields[:date].id.to_s => {value: '2014-02-20'},
            custom_fields[:int].id.to_s => {value: 93},
            custom_fields[:enum].id.to_s => {
              value: custom_fields[:enum].enumeration.values.last.numerical_value
            }
          }
        })
      end

      {
        string: 'Example',
        text: 'description of Example',
        date: '2014-02-20',
        int: 93,
        enum: 'high'
      }.each do |key, value|
        it "for #{key} type" do
          ready(test_run, valid_attributes_with_custom_fields)
          sign_in user
          put :update, {project_id: project.id, campaign_id: campaign.id, id: test_run.to_param, test_run: valid_attributes_with_custom_fields}
          custom_field_value = ::Tmt::TestRun.last.custom_field_values.where(custom_field: custom_fields[key]).first
          custom_field_value.value.should eq(value)
        end
      end

    end

  end

  describe "POST set_status_new" do

    it_should_not_authorize(self, [:no_logged, :foreign]) do
      test_run = Tmt::TestRun.create!(valid_attributes)
      post :set_status_new, {project_id: project.id, campaign_id: campaign.id, id: test_run.id}
    end

    it "should set test run into status new" do
      sign_in user
      Tmt::TestRun.any_instance.stub(:versions) { [1, 2] }
      test_run = Tmt::TestRun.create!(valid_attributes)
      test_run.update(due_date: Time.now)
      test_run.update(status: 2)
      put :set_status_new, {project_id: project.id, campaign_id: campaign.id, id: test_run.id}
      test_run.reload.status.should eq(1)
    end

    it "shouldn't set test run into status new" do
      sign_in user
      Tmt::TestRun.any_instance.stub(:versions) { [1, 2] }
      test_run = Tmt::TestRun.create!(valid_attributes)
      test_run.update(due_date: Time.now)
      test_run.update(status: 3)
      put :set_status_new, {project_id: project.id, campaign_id: campaign.id, id: test_run.id}
      test_run.reload.status.should_not eq(1)
    end

  end

  describe "POST set_status_planned" do

    it_should_not_authorize(self, [:no_logged, :foreign]) do
      test_run = Tmt::TestRun.create!(valid_attributes)
      post :set_status_planned, {project_id: project.id, campaign_id: campaign.id, id: test_run.id}
    end

    it "should set test run into planned" do
      sign_in user
      Tmt::TestRun.any_instance.stub(:versions) { [1, 2] }
      test_run = Tmt::TestRun.create!(valid_attributes)
      test_run.update(due_date: Time.now)
      put :set_status_planned, {project_id: project.id, campaign_id: campaign.id, id: test_run.id}
      response.should redirect_to(project_campaign_test_run_path(project, campaign, test_run))
    end

    it "shouldn't set test run into planned when due_date isn't setup" do
      sign_in user
      Tmt::TestRun.any_instance.stub(:versions) { [1, 2] }

      test_run = Tmt::TestRun.create!(valid_attributes)
      test_run.update(due_date: nil)
      post :set_status_planned, {campaign_id: campaign.id, project_id: project.id, id: test_run.id}
      response.should render_template('show')
    end

    it "shouldn't set test run into planned when executor isn't setup" do
      sign_in user

      test_run = Tmt::TestRun.create!(valid_attributes.merge({executor_id: nil}))
      post :set_status_planned, {campaign_id: campaign.id, project_id: project.id, id: test_run.id}
      response.should render_template('show')
    end

  end


  describe "DELETE destroy" do
    before do
      ready(test_run)
    end

    it "destroys the requested test_run" do
      sign_in user
      delete :destroy, {project_id: project.id, campaign_id: campaign.id, :id => test_run.to_param}
      test_run.reload.deleted_at.should_not be_nil
    end

    it "redirects to the test_runs list" do
      sign_in user
      delete :destroy, {campaign_id: campaign.id, project_id: project.id, id: test_run.to_param}
      response.should redirect_to(project_test_runs_path(project))
    end

    it "doesn't delete the test_run when campaign is closed" do
      sign_in user
      campaign.close
      delete :destroy, {project_id: project.id, campaign_id: campaign.id, :id => test_run.to_param}
      test_run.reload.deleted_at.should be_nil
    end

    it "doesn't update the test_run when status is 'done' or 'error'" do
      sign_in user
      test_run.update(status: 2)
      delete :destroy, {project_id: project.id, campaign_id: campaign.id, :id => test_run.to_param, project_id: project.id}
      test_run.reload.deleted_at.should be_nil
    end

    it_should_not_authorize(self, [:no_logged, :foreign]) do
      delete :destroy, {project_id: project.id, campaign_id: campaign.id, :id => test_run.to_param, project_id: project.id}
      test_run.reload.deleted_at.should be_nil
    end

  end

  context 'GET report' do
    it_should_not_authorize(self, [:no_logged, :foreign]) do
      ready(test_run, project, campaign)
      get :report, {campaign_id: campaign.id, id: test_run.id, project_id: project.id}
    end

    it "should download a report about execution" do
      sign_in user
      ready(test_run, project, campaign)
      get :report, {campaign_id: campaign.id, :id => test_run.id, project_id: project.id, format: :pdf}
      response.header['Content-Type'].should eql 'application/pdf'
    end
  end

end
