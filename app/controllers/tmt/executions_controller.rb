class Tmt::ExecutionsController < ApplicationController
  require 'extended_active_record'
  before_action :authenticate_user!

  before_action :set_execution, only: [:update, :show, :download_attached_file, :report, :report_file]

  def show
    @test_run = @execution.test_run
    @project = @test_run.project
    authorize! :member, @project
    @test_case = @execution.version.test_case
    @executor = @test_run.executor
    if can?(:planned_or_executing, @test_run) and @execution.can_be_executed?
      @execution.set_executing
      @execution.save
    end
    @version = @execution.version
    @author = @version.author
    @campaign = @test_run.campaign
  end

  # Push TestCaseVersions to TestRun
  def push_versions
    @test_run = Tmt::TestRun.find(params[:test_run_id])
    @project = @test_run.project
    @campaign = @test_run.campaign
    @used_version_ids = Tmt::Execution.where(test_run_id: @test_run.id).pluck(:version_id)
    authorize! :member, @project
    authorize! :editable, @test_run
    @version_ids = params[:version_ids] || []
    set_test_cases
    respond_to do |format|
      if @test_run.push_versions(params[:version_ids])
        format.html { redirect_to project_campaign_test_run_url(@project, @campaign, @test_run) }
        format.js { js_redirect_to project_campaign_test_run_url(@project, @campaign, @test_run) }
      else
        flash.now[:alert] = t(:alert_for_push_version, scope: [:controllers, :executions])
        format.html { render 'select_versions' }
        format.js { render 'select_versions', layout: false }
      end
    end
  end

  # PATCH/PUT /projects/x/campaigns/y/executions/z
  def update
    authorize! :planned_or_executing, @execution.test_run
    @execution.set_executing
    @test_run = @execution.test_run
    @version = @execution.version
    @campaign = @execution.test_run.campaign
    @project = @campaign.project
    if @execution.update_for_user(execution_params)
      notice_successfully_updated(@execution)
      url = project_campaign_test_run_url(@project, @campaign, @execution.test_run)
      respond_to do |format|
        format.html { redirect_to url}
        format.js { render js: "window.location.href='#{url}'"}
      end
    else
      respond_to do |format|
        format.html { render 'update' }
        format.js { render 'update', layout: false }
      end
    end
  end

  # Relationships of actions
  #  ----< select_test_cases (or sets)
  #  |         |
  #  |         v
  #  |     select_test_run
  #  |         |      ^
  #  |         v      |
  #  ----> select_version
  #            |
  #            v
  #        push_versions
  #
  def select_test_cases
    @test_run = Tmt::TestRun.find(params[:test_run_id])
    @project = @test_run.project
    authorize! :member, @project

    @campaign = @test_run.campaign
    @search = Tmt::TestCaseSearcher.new(
      project: @project,
      user: current_user,
      params: params,
      controller: self
    )
    @test_cases = @search.with_filter
    @test_cases = @test_cases.undeleted
    @version_ids = Tmt::Execution.where(test_run_id: params[:test_run_id]).pluck(:version_id)

    if @project.present? and current_user.present?
      @member = ::Tmt::Member.where(project: @project, user: current_user).first
      @set_ids = @member.set_ids || []
      @set_ids = @member.updated_set_ids(params[:add_set_id], params[:remove_set_id]) if @project_member
      @member.set_nav_tab(:execution, params[:nav_tab])
    end

    @sets = Tmt::Set.includes(:children).where(project_id: @project.id, parent_id: nil)

    @hash_tree = Tmt::Set.hash_tree(@project, @test_cases)

    respond_to do |format|
      format.html
      format.js { render layout: false }
    end
  end

  def select_versions
    @test_run = Tmt::TestRun.find(params[:test_run_id])
    @project = @test_run.project
    @campaign = @test_run.campaign
    @used_version_ids = Tmt::Execution.where(test_run_id: @test_run.id).pluck(:version_id)
    authorize! :member, @project
    @version_ids = params[:version_ids]
    set_test_cases
    respond_to do |format|
      format.html
      format.js { render layout: false }
    end
  end

  def select_test_run
    @project = Tmt::Project.find(params[:project_id])
    @campaign = @project.open_campaign
    authorize! :member, @project
    @test_runs = @campaign.new_test_runs.undeleted
    set_test_cases

    if params[:test_run_id] == ""
      flash[:alert] = t(:alert_for_select_test_run, scope: [:controllers, :executions])
    end
    respond_to do |format|
      format.html
      format.js { render layout: false }
    end
  end

  def download_attached_file
    @test_run = @execution.test_run
    @campaign = @test_run.campaign
    @project = @campaign.project
    authorize! :member, @project
    path = @execution.find_file_path(params[:uuid])
    filename = @execution.read_original_filename_from_path(path)
    data = Tmt::Lib::Gzip.decompress_from(path)
    send_data(data, filename: filename)
  end

  def destroy
    version = Tmt::Execution.find(params[:id])
    @test_run = version.test_run
    @campaign = @test_run.campaign
    @project = @campaign.project
    authorize! :member, @project
    authorize! :editable, @test_run
    version.destroy
    respond_to do |format|
      notice_successfully_destroyed(@execution)
      format.html { redirect_to project_campaign_test_run_url(@project, @campaign, @test_run)}
    end
  end

  def report
    @test_run = @execution.test_run
    @campaign = @test_run.campaign
    @project = @campaign.project
    authorize! :member, @project
    @version = @execution.version
    @author = @version.author
    @test_case = @version.test_case
  end

  def report_file
    @test_run = @execution.test_run
    @campaign = @test_run.campaign
    @project = @campaign.project
    authorize! :member, @project
    render layout: false
  end

  #  upload_csv <--------
  #        |            |
  #        |-------------
  #        |
  #        |
  #  accept_csv <--------
  #        |            |
  #        |-------------
  #        |
  #  select_versions
  #        |
  #        v
  #    push_versions
  #
  def upload_csv
    @test_run = Tmt::TestRun.find(params[:test_run_id])
    @project = @test_run.project
    @campaign = @test_run.campaign
    authorize! :member, @project
  end

  def accept_csv
    @test_run = Tmt::TestRun.find(params[:test_run_id])
    @project = @test_run.project
    @campaign = @test_run.campaign
    authorize! :member, @project

    begin
      set_array_csv(params[:datafile], @project)
    rescue
      @error_message = t(:file_is_incorrect, scope: [:controllers, :executions])
    end
    respond_to do |format|
      if @error_message
        flash.now[:alert] = @error_message
        format.html { render 'upload_csv' }
      else
        @used_version_ids = Tmt::Execution.where(test_run_id: @test_run.id).pluck(:version_id)
        params[:test_case_ids] = @test_case_ids
        set_test_cases
        format.html { render 'select_versions' }
      end
    end
  end

  private

  def set_array_csv(file, project)
    file.rewind
    csv = ::CSV.parse(file.read, {col_sep: ',', headers: true})
    test_cases = project.undeleted_test_cases
    @test_case_ids = test_cases.where(name: csv['name']).ids
    @test_case_ids += test_cases.where(id: csv['id']).ids
    @test_case_ids = @test_case_ids.uniq.map(&:to_s)
  end

  def set_test_cases
    if params[:set_id]
      set = ::Tmt::Set.where(id: params[:set_id]).first
      @test_cases = set.posterity_test_cases_for(@project).includes(:versions)
    end
    @test_cases ||= @project.test_cases.where(id: params[:test_case_ids]).includes(:versions)
    @test_cases = @test_cases.undeleted
  end

  def execution_params
    params.require(:execution).permit(:progress, :status, :comment, datafiles: [])
  end

  def set_execution
    @execution = Tmt::Execution.find(params[:id])
  end

end
