module Admin
  class CustomFieldTypesController < ApplicationController
    before_action :authenticate_user!

    # GET /admin/custom-field-types/change
    def change
      authorize! :manage, Tmt::CustomFieldType
      @type_name = params[:type_name]
      @enumerations = ::Tmt::Enumeration.all

      respond_to do |format|
        format.js { render layout: false}
      end
    end
  end
end
