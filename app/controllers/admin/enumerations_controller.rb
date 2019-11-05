module Admin
  class EnumerationsController < ApplicationController
    before_action :authenticate_user!

    before_action :set_enumeration, only: [:show, :edit, :update, :destroy]

    # GET admin/enumerations
    # GET admin/enumerations.json
    def index
      authorize! :lead, ::Tmt::Enumeration
      @enumerations = ::Tmt::Enumeration.all
    end

    # GET admin/enumerations/new
    def new
      authorize! :lead, ::Tmt::Enumeration
      @enumeration = ::Tmt::Enumeration.new
      respond_to do |format|
        format.html
        format.js { render layout: false }
      end
    end

    # GET admin/enumerations/1/edit
    def edit
      authorize! :lead, ::Tmt::Enumeration
    end

    # POST admin/enumerations
    # POST admin/enumerations.json
    def create
      authorize! :lead, ::Tmt::Enumeration

      @enumeration = ::Tmt::Enumeration.new(enumeration_params)

      respond_to do |format|
        if @enumeration.save
          notice_successfully_created(@enumeration)
          format.html { redirect_to back_or_customize_url(@enumeration, admin_enumerations_url) }
          format.js { render layout: false }
        else
          format.html { render 'new' }
          format.js { render 'new' }
        end
      end
    end

    # PATCH/PUT admin/enumerations/1
    # PATCH/PUT admin/enumerations/1.json
    def update
      authorize! :lead, ::Tmt::Enumeration
      respond_to do |format|
        if @enumeration.update(enumeration_params)
          notice_successfully_updated(@enumeration)
          format.html { redirect_to admin_enumerations_url }
          format.js { render layout: false }
        else
          format.html { render 'edit' }
        end
      end
    end

    # DELETE admin/enumerations/1
    def destroy
      authorize! :lead, ::Tmt::Enumeration
      @enumeration.destroy
      respond_to do |format|
        notice_successfully_destroyed(@enumeration)
        format.html { redirect_to admin_enumerations_url }
      end
    end

    private

    # Use callbacks to share common setup or constraints between actions.
    def set_enumeration
      @enumeration = ::Tmt::Enumeration.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def enumeration_params
      params.require(:enumeration).permit(:test_case_custom_field_id, :test_run_custom_field_id, :name)
    end
  end
end
