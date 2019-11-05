module Admin
  class EnumerationValuesController < ::ApplicationController
    before_action :authenticate_user!

    before_action :set_enumeration, only: [:edit, :new, :update, :create]
    before_action :set_enumeration_value, only: [:edit, :update, :destroy]

    def new
      authorize! :lead, ::Tmt::Enumeration
      @value = ::Tmt::EnumerationValue.new
      @value.enumeration = @enumeration
      @value.numerical_value = @enumeration.first_free_int_value

      respond_to do |format|
        format.html
        format.js { render layout: false }
      end
    end

    def edit
      authorize! :lead, ::Tmt::Enumeration
      respond_to do |format|
        format.html
        format.js { render layout: false }
      end
    end

    def create
      authorize! :lead, ::Tmt::Enumeration
      @value = ::Tmt::EnumerationValue.new(enumeration_value_params)
      @value.enumeration_id = params[:enumeration_id]

      respond_to do |format|
        if @value.save
          notice_successfully_created(@value, :also_now)
          format.html { redirect_to admin_enumerations_url }
          format.js { js_reload_page }
        else
          format.html { render 'new'}
          format.js { render 'new' }
        end
      end
    end

    def destroy
      authorize! :lead, ::Tmt::Enumeration
      respond_to do |format|
        if @value.destroy
          notice_successfully_destroyed(@value)
          format.html { redirect_to admin_enumerations_url }
        else
          format.html { redirect_to admin_enumerations_url, alert: @value.errors[:base].first }
        end
      end
    end

    def update
      authorize! :lead, ::Tmt::Enumeration
      respond_to do |format|
        if @value.update(edit_enumeration_value_params)
          notice_successfully_updated(@value, :also_now)
          format.html { redirect_to admin_enumerations_url }
          format.js { js_reload_page }
        else
          format.html { render 'edit' }
          format.js { render 'edit' }
        end
      end
    end

    private

    def set_enumeration
      @enumeration = ::Tmt::Enumeration.find(params[:enumeration_id])
    end

    def enumeration_value_params
      params.require(:enumeration_value).permit(:numerical_value, :text_value)
    end

    def edit_enumeration_value_params
      params.require(:enumeration_value).permit(:numerical_value, :text_value)
    end

    def set_enumeration_value
      @value = ::Tmt::EnumerationValue.find(params[:id])
    end
  end
end
