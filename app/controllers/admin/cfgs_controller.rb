module Admin
  class CfgsController < ApplicationController
    before_action :authenticate_user!

    # GET /cfgs
    # GET /cfgs.json
    def index
      authorize! :manage, Tmt::Cfg
      @cfg = Tmt::Cfg.first
    end

    # PATCH/PUT /cfgs/1
    def update
      authorize! :manage, Tmt::Cfg
      respond_to do |format|
        if @cfg.update(cfg_params)
          @cfg.reload
          notice_successfully_updated(@cfg)
          format.html { redirect_to admin_cfgs_url}
        else
          format.html { render 'index' }
        end
      end
    end

    private

    # Never trust parameters from the scary internet, only allow the white list through.
    def cfg_params
      params.require(:cfg).permit(:instance_name, :records_per_page, :file_size, :hello_subtitle, :hello_message, :max_name_length, :time_zone, :user_creates_account)
    end
  end
end
