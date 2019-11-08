require 'spec_helper'

describe Tmt::ExecutionsController do
  require 'tempfile'

  extend CanCanHelper

  let(:admin) { create(:admin) }

  let(:user) do
    user = create(:user)
    project.add_member(user)
    user
  end

  let(:test_case) { create(:test_case, project: project) }
  let(:campaign) { create(:campaign, project: project) }
  let(:project) { create(:project) }

  let(:version) { create(:test_case_version, test_case: test_case, revision: "hash") }

  let(:test_run) { create(:test_run, campaign: campaign) }

  let(:execution) { Tmt::Execution.create(test_run: test_run, version: version) }

  describe "GET show" do
    it_should_not_authorize(self, [:foreign, :no_logged]) do
      ready(test_run, execution)

      get :show, project_id: project.id, campaign_id: campaign.id, id: execution.id
      assigns(:campaign).should be_nil
      assigns(:test_case).should be_nil
    end

    it "should assign campaign and test_case" do
      sign_in user
      ready(test_run, execution)

      get :show, project_id: project.id, campaign_id: campaign.id, id: execution.id
      assigns(:campaign).should eq(campaign)
      assigns(:test_case).should eq(test_case)
    end

    it "should change status on executing when executor visits execution view" do
      sign_in user
      ready(test_run, execution)
      test_run.update(executor: user)
      test_run.set_status_planned
      test_run.set_status_executing
      get :show, project_id: project.id, campaign_id: campaign.id, id: execution.id
      execution.reload.status.should eq('executing')
    end

    it "should change status on executing when admin visits execution view" do
      sign_in admin
      ready(test_run, execution)
      test_run.update(executor: user)
      test_run.set_status_planned
      test_run.set_status_executing
      get :show, project_id: project.id, campaign_id: campaign.id, id: execution.id
      execution.reload.status.should eq('none')
    end

    it "should not change status on executing when user visits execution view and isn't executor" do
      sign_in create(:user)
      ready(test_run, execution)
      test_run.update(executor: user)
      test_run.set_status_planned
      test_run.set_status_executing
      get :show, project_id: project.id, campaign_id: campaign.id, id: execution.id
      execution.reload.status.should eq('none')
    end

  end

  describe "POST push_versions" do
    [:html, :js].each do |format|
      it "pushes ids of versions when user is logged for format #{format}" do
        sign_in user
        ready(test_run)
        expect do
          post :push_versions, {project_id: project.id, campaign_id: campaign.id, test_run_id: test_run.id, version_ids: [version.id, "0"], format: format}
        end.to change(Tmt::Execution, :count).by(1)
      end

      it "doesn't push ids of versions when user isn't logged for format #{format}" do
        ready(test_run)
        expect do
          post :push_versions, {campaign_id: campaign.id, project_id: project.id, versions_run: { test_run_id: test_run.id, version_ids: [version.id, "0"]}, format: format}
        end.to change(Tmt::Execution, :count).by(0)
      end
    end

    it "redirects to test_run page for format html" do
      sign_in user
      ready(test_run)
      post :push_versions, {project_id: project.id, campaign_id: campaign.id, test_run_id: test_run.id, version_ids: [version.id, "0"]}
      response.should redirect_to(project_campaign_test_run_path(project, campaign, test_run))
    end

    it "redirects to test_run page for format js" do
      sign_in user
      ready(test_run)
      post :push_versions, {project_id: project.id, campaign_id: campaign.id, test_run_id: test_run.id, version_ids: [version.id, "0"], format: :js}
      response.status.should eq(200)
    end

  end

  describe "POST GET select_test_cases" do
    before do
      ready(test_run, test_case, project)
    end

    it_should_not_authorize(self, [:foreign, :no_logged]) do
      post :select_test_cases, project_id: project.id, campaign_id: campaign.id, test_run_id: test_run.id
    end

    [:html, :js].each do |format|
      it "should render flat view for format #{format}" do
        sign_in user
        post :select_test_cases, project_id: project.id, campaign_id: campaign.id, test_run_id: test_run.id, format: format
        assigns(:project).should eq(project)
        assigns(:campaign).should eq(campaign)
        assigns(:test_cases).should match_array([test_case])
      end

      it "should render tree view for format #{format}" do
        sign_in user
        member = user.member_for_project(project)
        member.update(nav_tab: {execution: :sets})
        post :select_test_cases, project_id: project.id, campaign_id: campaign.id, test_run_id: test_run.id, format: format
        assigns(:project).should eq(project)
        assigns(:campaign).should eq(campaign)
        assigns(:test_cases).should match_array([test_case])
      end

    end
  end

  describe "POST GET select_test_run" do
    before do
      ready(test_run, test_case, project)
    end

    it_should_not_authorize(self, [:foreign, :no_logged]) do
      post :select_test_run, project_id: project.id, campaign_id: campaign.id, test_cases: [test_case.id]
    end

    [:html, :js].each do |format|
      describe "for format #{format}" do
        it "with seted test_run_id for format #{format}" do
          sign_in user
          post :select_test_run, project_id: project.id, campaign_id: campaign.id, test_run_id: test_run.id, format: format
          assigns(:project).should eq(project)
          assigns(:campaign).should eq(campaign)
        end

        it "without seted test_run_id" do
          sign_in user
          post :select_test_run, project_id: project.id, campaign_id: campaign.id, format: format
          assigns(:project).should eq(project)
          assigns(:campaign).should eq(campaign)
          assigns(:test_runs).should eq([test_run])
          flash[:alert].should be_nil
        end

        it "seted empty test_run_id" do
          sign_in user
          post :select_test_run, project_id: project.id, campaign_id: campaign.id, test_run_id: '', format: format
          flash[:alert].should eq('Please select test run')
          assigns(:project).should eq(project)
          assigns(:campaign).should eq(campaign)
          assigns(:test_runs).should eq([test_run])
        end
      end
    end
  end

  describe "POST GET select_versions" do
    before do
      ready(test_run, test_case, project)
    end

    it_should_not_authorize(self, [:foreign, :no_logged]) do
      post :select_versions, project_id: project.id, campaign_id: campaign.id, test_case_ids: [test_case.id], test_run_id: test_run.id
    end

    [:html, :js].each do |format|
      describe "for format #{format}" do
        it "with seted test_case_ids for format #{format}" do
          sign_in user
          post :select_versions, project_id: project.id, campaign_id: campaign.id, test_run_id: test_run.id, test_case_ids: [test_case.id.to_s], version_ids: ['1'], format: format
          assigns(:project).should eq(project)
          assigns(:campaign).should eq(campaign)
          assigns(:test_cases).should eq([test_case])
          assigns(:version_ids).should eq(['1'])
        end

        it "with set_id parameter for format #{format}" do
          sign_in user
          create(:test_case)
          set = create(:set, project: project)
          set.test_cases << test_case
          post :select_versions, project_id: project.id, campaign_id: campaign.id, test_run_id: test_run.id, set_id: set.id, format: format
          assigns(:project).should eq(project)
          assigns(:campaign).should eq(campaign)
          assigns(:test_cases).should eq([test_case])
        end
      end
    end
  end

  describe "DELETE destroy" do
    it_should_not_authorize(self, [:foreign, :no_logged]) do
      ready(test_run)
      object = Tmt::Execution.create(test_run_id: test_run.id)

      expect do
        delete :destroy, project_id: project.id, campaign_id: campaign.id, id: object.id
      end.to change(Tmt::Execution, :count).by(0)
    end
    it_should_not_authorize(self, ['self.user']) do
      ready(test_run)
      test_run.update(status: 2)
      object = Tmt::Execution.create(test_run_id: test_run.id)

      expect do
        delete :destroy, project_id: project.id, campaign_id: campaign.id, id: object.id
      end.to change(Tmt::Execution, :count).by(0)
    end

    it "can destroy record when user is logged" do
      sign_in user
      ready(test_run)
      object = Tmt::Execution.create(test_run_id: test_run.id)

      expect do
        delete :destroy, project_id: project.id, campaign_id: campaign.id, id: object.id
      end.to change(Tmt::Execution, :count).by(-1)
    end

  end

  describe "GET download_attached_file" do
    it "should download attached file of execution result" do
      sign_in user
      ready(test_run)
      clean_execution_repository
      execution = create(:execution_for_passed, test_run_id: test_run.id)

      attached_file = execution.attached_files.first
      get :download_attached_file, project_id: project.id, campaign_id: campaign.id, id: execution.id, uuid: attached_file[:uuid]
      response.body.should eq(Tmt::Lib::Gzip.decompress_from(attached_file[:compressed_file].path))
    end
  end

  describe "GET report" do
    let(:execution) { create(:execution) }
    let(:version) { execution.version }
    let(:test_run) { execution.test_run }
    let(:test_case) { execution.test_case }
    let(:campaign) { test_run.campaign }
    let(:project) { campaign.project }

    let(:member) do
      user = create(:user)
      project.add_member(user)
      user
    end

    let(:member_john) do
      user = create(:user)
      project.add_member(user)
      user
    end

    it_should_not_authorize(self, [:foreign, :no_logged]) do
      test_run.update(executor: member_john, due_date: Time.now)
      test_run.set_status_planned
      get :report, project_id: project.id, campaign_id: campaign.id, id: execution.id
    end

    it "should authorize member of project" do
      test_run.update(executor: member_john, due_date: Time.now)
      test_run.set_status_planned
      sign_in member

      get :report, project_id: project.id, campaign_id: campaign.id, id: execution.id
      response.should_not redirect_to(root_path)
    end

    it "should show name of comment" do
      test_run.update(executor: member, due_date: Time.now)
      test_run.set_status_planned
      sign_in member

      get :report, project_id: project.id, campaign_id: campaign.id, id: execution.id
      assigns(:author).should eq(version.author)
    end
  end

  describe "GET report_file" do
    let(:execution) { create(:execution) }
    let(:version) { execution.version }
    let(:test_run) { execution.test_run }
    let(:campaign) { test_run.campaign }
    let(:project) { campaign.project }

    let(:member) do
      user = create(:user)
      project.add_member(user)
      user
    end

    it_should_not_authorize(self, [:foreign, :no_logged]) do
      test_run.update(executor: member, due_date: Time.now)
      test_run.set_status_planned
      get :report_file, project_id: project.id, campaign_id: campaign.id, id: execution.id
    end
  end

  describe "PUT update" do
    let(:member_john) do
      user = create(:user)
      project.add_member(user)
      user
    end

    before do
      ready execution
      test_run = execution.test_run
      test_run.update(status: 2, executor: user)
    end

    it_should_not_authorize(self, [:foreign, :no_logged, 'self.member_john']) do
      put :update, project_id: project.id, campaign_id: campaign.id, id: execution.id, execution: {status: :passed, comment: 'Comments'}
      test_run.reload.has_status?(:done).should be false
    end

    [:js, :html].each do |format|
      it "only executor can update execution" do
        sign_in user
        put :update, project_id: project.id, campaign_id: campaign.id, id: execution.id, execution: {status: :passed, comment: 'Comments'}, format: format
        test_run.reload.has_status?(:done).should be true
      end

      it "executor can update execution with status none" do
        sign_in user
        put :update, project_id: project.id, campaign_id: campaign.id, id: execution.id, execution: {comment: 'Comments'}, format: format
        test_run.reload.has_status?(:done).should be false
      end

      it "executor cannot update execution with status passed" do
        execution.update(status: 'passed', comment: 'Example')
        execution.reload.status.should eq 'passed'
        sign_in user
        put :update, project_id: project.id, campaign_id: campaign.id, id: execution.id, execution: {status: 'failed', comment: 'Comments'}, format: format
        execution.reload.status.should eq 'passed'
      end
    end
  end

  describe "GET upload_csv" do
    it_should_not_authorize(self, [:foreign, :no_logged]) do
      get :upload_csv, campaign_id: campaign.id, project_id: project.id, test_run_id: test_run.id
    end

    it "should properly generate view" do
      sign_in user
      expect do
        get :upload_csv, campaign_id: campaign.id, project_id: project.id, test_run_id: test_run.id
      end.to_not raise_error
    end

    it "assigns test_run as @test_run variable" do
      sign_in user
      get :upload_csv, campaign_id: campaign.id, project_id: project.id, test_run_id: test_run.id
      assigns(:test_run).should eq(test_run)
    end

    it "assigns project as @project variable" do
      sign_in user
      get :upload_csv, campaign_id: campaign.id, project_id: project.id, test_run_id: test_run.id
      assigns(:project).should eq(project)
    end

    it "assigns campaign as @campaign variable" do
      sign_in user
      get :upload_csv, campaign_id: campaign.id, project_id: project.id, test_run_id: test_run.id
      assigns(:campaign).should eq(campaign)
    end
  end

  describe "POST accept_csv" do
    let(:test_case) { create(:test_case, project: project)}
    let(:test_case_next) { create(:test_case, project: project)}
    let(:third_test_case) { create(:test_case, project: project)}

    let(:uploaded_file) do
      file = Tempfile.new('list_test_cases.csv')
      file << "id,name\n"
      file << "#{test_case.id},#{test_case.name}\n"
      file << "#{test_case_next.id},#{test_case_next.name}\n"
      file << "#{create(:test_case).id},Example test case\n"
      ::ActionDispatch::Http::UploadedFile.new({
        filename: 'dadfas',
        content_type: 'text/plain',
        tempfile: file
      })
    end

    let(:uploaded_file_mix) do
      file = Tempfile.new('list_test_cases.csv')
      file << "id,name\n"
      file << "#{test_case.id},\n"
      file << ",#{test_case_next.name}\n"
      file << ",#{test_case_next.name}\n"
      file << ",doesn't exists\n"
      ::ActionDispatch::Http::UploadedFile.new({
        filename: 'dadfas',
        content_type: 'text/plain',
        tempfile: file
      })
    end

    it_should_not_authorize(self, [:foreign, :no_logged]) do
      get :accept_csv, campaign_id: campaign.id, project_id: project.id, test_run_id: test_run.id
    end

    it "should not accept when datafile attribute is blank" do
      sign_in user
      expect do
        get :accept_csv, campaign_id: campaign.id, project_id: project.id, test_run_id: test_run.id
      end.to_not raise_error
      flash[:alert].should eq('File is incorrect')
      request.should render_template('upload_csv')
    end

    it "assigns array_csv from uploaded csv file when 'id' is set up" do
      sign_in user
      post :accept_csv, campaign_id: campaign.id, project_id: project.id, test_run_id: test_run.id, datafile: uploaded_file
      assigns(:test_case_ids).should match_array([test_case.id.to_s, test_case_next.id.to_s])
      request.should render_template('select_versions')
    end

    it "assigns array_csv from uploaded csv file when 'name' is set up" do
      sign_in user
      post :accept_csv, campaign_id: campaign.id, project_id: project.id, test_run_id: test_run.id, datafile: uploaded_file_mix
      assigns(:test_case_ids).should match_array([test_case.id.to_s, test_case_next.id.to_s])
      request.should render_template('select_versions')
    end
=begin
    it "should show error message when datafile has got incorrectly file" do
      sign_in user
      post :accept_csv, campaign_id: campaign.id, project_id: project.id, test_run_id: test_run.id, datafile: ::CommonHelper.uploaded_file('binary_file.zip')
      flash.alert.should eq('File is incorrect')
    end

    it "should render upload_csv when datafile has got incorrectly file" do
      sign_in user
      post :accept_csv, campaign_id: campaign.id, project_id: project.id, test_run_id: test_run.id, datafile: ::CommonHelper.uploaded_file('binary_file.zip')
      request.should render_template('upload_csv')
    end
=end
  end
end
