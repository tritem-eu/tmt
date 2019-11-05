module Admin
  class CampaignsController < ApplicationController
    before_action :authenticate_user!

    before_action :set_campaign_and_project, only: [:edit, :update, :close]

    # GET /campaigns
    def index
      authorize! :lead, Tmt::Campaign

      @projects = Tmt::Project.all
      if @projects.any?
        @project_id = params[:project_id] || @projects.first.id
        @project = @projects.where(id: @project_id).first
        @new_campaign = Tmt::Campaign.new(project_id: @project_id)
        @campaigns = Tmt::Campaign.where(project_id: @project.id).order(created_at: :desc)
        @amount_test_runs_per_campaign = @project.undeleted_test_runs.group(:campaign).count
        @amount_done_test_runs_per_campaign = @project.done_test_runs.group(:campaign).count
        @exist_open_campaign = true
      end
    end

    # GET /campaigns/new
    def new
      authorize! :lead, Tmt::Campaign
      @project = ::Tmt::Project.find(params[:project_id])
      @campaign = ::Tmt::Campaign.new(project_id: @project.id)

      respond_to do |format|
        format.html
        format.js {render layout: false}
      end
    end

    # GET /campaigns/1/edit
    def edit
      authorize! :edit, @campaign
      @project = @campaign.project

      respond_to do |format|
        format.html
        format.js {render layout: false}
      end
    end

    # POST /campaigns
    def create
      authorize! :lead, Tmt::Campaign
      @campaign = Tmt::Campaign.new(campaign_params)
      @project = @campaign.project

      respond_to do |format|
        if @campaign.save
          format.html do
            notice_successfully_created(@campaign)
            redirect_to admin_campaigns_url(project_id: @project.id)
          end
          format.js { js_redirect_to admin_campaigns_url(project_id: @project.id)}
        else
          @projects = Tmt::Project.all
          format.html { render 'index' }
          format.js { render layout: false }
        end
      end
    end

    # PATCH/PUT /campaigns/1
    def update
      authorize! :lead, Tmt::Campaign
      @project = @campaign.project

      respond_to do |format|
        if @campaign.update(edit_campaign_params)
          format.html do
            notice_successfully_updated @campaign
            redirect_to admin_campaigns_url(project_id: @project.id)
          end
          format.js { js_redirect_to admin_campaigns_url(project_id: @project.id) }
        else
          format.html { render 'edit' }
          format.js { render layout: false }
        end
      end
    end

    def close
      authorize! :lead, @campaign
      project = @campaign.project

      respond_to do |format|
        if can?(:close, @campaign) and @campaign.close
          format.html {
            notice_successfully_closed(@campaign)
            redirect_to admin_campaigns_url(project_id: project.id)
          }
        else
          format.html { redirect_to(
            admin_campaigns_url(project_id: project.id),
            alert: t(:alert_for_close, scope: [:controllers, :campaigns])
          ) }
        end
      end
    end

    # GET /campaigns/info
    def info
    end

    private

    # Use callbacks to share common setup or constraints between actions.
    def set_campaign_and_project
      @campaign = Tmt::Campaign.find(params[:id])
      @project = @campaign.project
    end

    def campaign_params
      params.require(:campaign).permit(:name, :project_id, :deadline_at)
    end

    def edit_campaign_params
      params.require(:campaign).permit(:name, :deadline_at)
    end

  end
end
