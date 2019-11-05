module Tmt
  class CampaignsController < ApplicationController
    before_action :authenticate_user!

    before_action :set_campaign_and_project, only: [:show]

    # GET /campaigns/1
    def show
      @project = @campaign.project
      authorize! :member, @project
      @test_runs = @campaign.undeleted_test_runs
      @done_test_runs = @campaign.done_test_runs
    end

    private

    def set_campaign_and_project
      @campaign = Tmt::Campaign.find(params[:id])
      @project = @campaign.project
    end

  end
end
