module Admin
  class OslcCfgsController < ApplicationController
    before_action :authenticate_user!

    # GET admin/oslc/cfgs
    def index
      authorize! :manage, Tmt::OslcCfg
      @cfg = Tmt::Cfg.first
      @oslc_cfg = Tmt::OslcCfg.cfg
    end

    # PATCH/PUT admin/oslc/cfgs/1
    def update
      authorize! :manage, Tmt::OslcCfg
      respond_to do |format|
        @oslc_cfg = Tmt::OslcCfg.cfg
        if @oslc_cfg.update(cfg_params)
          @oslc_cfg.reload
          notice_successfully_updated(@oslc_cfgs)
          format.html { redirect_to admin_oslc_cfgs_url }
        else
          format.html { render 'index' }
        end
      end
    end

    private

    # Never trust parameters from the scary internet, only allow the white list through.
    def cfg_params
      params.require(:oslc_cfg).permit(:test_case_type_id)
    end
  end
end
