module Tmt
  class TestRunsController < ApplicationController
    before_action :authenticate_user!

    before_action :set_test_run, only: [:show, :edit, :update, :set_status_planned, :destroy, :set_status_new, :set_status_executing, :report]
    before_render :save_current_project, only: [:show]

    # GET /test_runs
    def index
      set_campaign_and_project
      authorize! :member, @project

      @search = Tmt::TestRunSearcher.new(
        params: params,
        action: :index,
        project: @project,
        user: current_user,
        controller: self
      )
      @test_runs = @search.with_filter
    end

    # GET test-runs/calendar
    def calendar
      set_campaign_and_project
      authorize! :member, @project
      if params['date']
        @year, @month = ::Tmt::Lib::Calendar.year_month_with(params[:date], params[:button])
      else
        member = current_user.member_for_project(@project)
        @year, @month = nested_hash(member.filters, :test_run, 'date', :due_date) || []
        @year ||= Time.now.year
        @month ||= Time.now.month
      end
      @search = Tmt::TestRunSearcher.new(
        params: params,
        project: @project,
        user: current_user,
        date: {due_date: [@year, @month]},
        controller: self
      )
      @test_runs = @search.with_filter
    end

    # GET test-runs/calendar-day
    def calendar_day
      @project = ::Tmt::Project.find(params[:project_id])
      authorize! :member, @project

      @year = params[:year].to_i
      @month = params[:month].to_i
      @day = params[:day].to_i
      @date = Date.new(@year, @month, @day)
      @search = Tmt::TestRunSearcher.new(
        params: params.clone,
        project: @project.reload,
        user: current_user.reload,
        date: {due_date: [@year, @month, @day]},
        controller: self
      )
      @test_runs = @search.with_filter
    end

    def clone
      set_test_run
      authorize! :member, @project
      notice_successfully_cloned(@test_run)
      redirect_to project_test_run_path(@project, @test_run.clone_record(creator: current_user))
    end

    def terminate
      set_test_run
      authorize! :terminate, @test_run
      @test_run.terminate(current_user)
      flash[:notice] = t(:notice_for_terminate, scope: [:controllers, :test_runs])
      redirect_to project_test_run_path(@project, @test_run)
    end

    # GET /test_runs/1
    def show
      authorize! :member, @project
      @member = current_user.member_for_project(@project)
      @test_run.reload_custom_field_values
      @versions = @test_run.executions
      @executor = @test_run.executor
      respond_to do |format|
        format.html
        format.js { render layout: false }
      end
    end

    # GET /campaigns/1/test_runs/new
    def new
      set_campaign_and_project
      @test_run = Tmt::TestRun.new(campaign: @campaign)
      authorize! :member, @project
      @project_users = @project.users
      @test_run.reload_custom_field_values
      respond_to do |format|
        format.html
        format.js { render layout: false }
      end
    end

    # GET /test-runs/1/edit
    def edit
      authorize! :editable, @test_run
      @project_users = @project.users
      @test_run.reload_custom_field_values
      respond_to do |format|
        format.html
        format.js { render layout: false }
      end
    end

    # POST /campaigns/1/test_runs
    def create
      @test_run = Tmt::TestRun.new(test_run_params)
      @test_run.campaign_id = params[:campaign_id]
      @test_run.creator = current_user

      authorize! :member, @test_run.project
      @campaign = @test_run.campaign
      authorize! :is_open, @campaign
      @project = @campaign.project
      @test_run.reload_custom_field_values(test_run_params[:custom_field_values])
      respond_to do |format|
        if @test_run.save
          @redirect_to = project_campaign_test_run_url(@project, @campaign, @test_run)
          notice_successfully_created(@test_run)
          format.html { redirect_to @redirect_to }
          format.js { render layout: false }
        else
          @project_users = @project.users
          format.html { render 'new' }
          format.js { render 'new', layout: false }
        end
      end
    end

    # PATCH/PUT /test_runs/1
    def update
      authorize! :editable, @test_run
      @campaign = @test_run.campaign
      @project = @campaign.project
      @test_run.reload_custom_field_values

      respond_to do |format|
        if @test_run.update(update_test_run_params)
          notice_successfully_updated(@test_run)
          format.html { redirect_to [@project, @campaign, @test_run] }
          format.js { render layout: false }
        else
          @project_users = @project.users
          format.html { render 'edit' }
          format.js { render 'edit' }
        end
      end
    end

    # PUT /test-runs/1/planned
    def set_status_planned
      @campaign = @test_run.campaign
      @project = @campaign.project
      authorize! :member, @project
      respond_to do |format|
        if @test_run.set_status_planned
          format.html {redirect_to project_campaign_test_run_url(@project, @campaign, @test_run), notice: t(:notice_for_set_status_planned, scope: [:controllers, :test_runs])  }
        else
          @versions = @test_run.executions
          format.html { render :show }
        end
      end
    end

    def report
      authorize! :member, @test_run.project
      @versions = @test_run.executions
      pdf = Tmt::Lib::PDF::TestRunReport.new(@test_run, {:margins=>[0, 0, 0, 0], :paper=>"A5"})
      send_data pdf.render, filename: 'example.pdf', :type => "application/pdf", disposition: "inline"
    end

    # PUT /test-runs/1/execution
    def set_status_executing
      @campaign = @test_run.campaign
      @project = @campaign.project
      authorize! :member, @project
      respond_to do |format|
        if @test_run.set_status_executing
          format.html {redirect_to project_campaign_test_run_url(@project, @campaign, @test_run), notice: t(:notice_for_set_status_executing, scope: [:controllers, :test_runs]) }
        else
          @versions = @test_run.executions
          format.html { render :show  }
        end
      end
    end

    def set_status_new
      @campaign = @test_run.campaign
      @project = @campaign.project
      authorize! :member, @project
      respond_to do |format|
        if @test_run.set_status_new
          format.html {redirect_to project_campaign_test_run_url(@project, @campaign, @test_run), notice: t(:notice_for_set_status_new, scope: [:controllers, :test_runs])}
        else
          @versions = @test_run.executions
          format.html { render :show  }
        end
      end
    end

    # DELETE /projects/1/campaigns/1/test-runs/1
    def destroy
      authorize! :editable, @test_run
      @project = @test_run.project
      @test_run.set_deleted
      Tmt::UserActivity.save_for_deleted_observable(@project, @test_run, current_user)
      notice_successfully_destroyed(@test_run)
      redirect_to back_or_customize_url(
        @test_run, project_test_runs_url(@project)
      )
    end

    private

    # Use callbacks to share common setup or constraints between actions.
    def set_test_run
      @test_run = Tmt::TestRun.find(params[:id])
      @campaign = @test_run.campaign
      @project = @campaign.project
    end

    def set_campaign_and_project
      if params[:campaign_id].present?
        @campaign = Tmt::Campaign.find(params[:campaign_id])
        @project = @campaign.project
      else
        @project = Tmt::Project.find(params[:project_id])
      end
    end

    # In this place system should set current browsing test_run_id
    def save_current_project
      if current_user
        if @test_run and @test_run.id
          project = @test_run.project
          if current_user.update(current_project: project)
            member = Tmt::Member.where(project: project, user: current_user).first
            member.update(current_test_run_id: @test_run.id) if member
          end
        end
      end
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def test_run_params
      params.require(:test_run).permit(:name, :description, :due_date, :executor_id, :campaign_id, :custom_field_values => [:value])
    end

    def update_test_run_params
      params.require(:test_run).permit(:name, :description, :due_date, :executor_id, :custom_field_values => [:value])
    end

  end
end
