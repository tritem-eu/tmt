module Admin
  class CustomFieldsController < ApplicationController
    before_action :authenticate_user!

    before_action :set_model_class
    before_action :set_custom_field, only: [:show, :edit, :update, :destroy]
    before_action :set_type_names, only: [:edit, :new, :update]
    before_action :set_type_name
    before_action :set_projects, only: [:edit, :new, :update]
    before_action :set_enumerations, only: [:new, :create]

    # GET /admin/test-case/custom-fields
    # GET /admin/test-run/custom-fields
    def index
      authorize! :manage, @model
      @custom_fields = @model.undeleted
    end

    # GET /admin/test-case/custom-fields/1
    # GET /admin/test-run/custom-fields/1
    def show
      authorize! :manage, @model
    end

    # GET /admin/test-case/custom_fields/new
    # GET /admin/test-run/custom_fields/new
    def new
      authorize! :manage, @model
      @custom_field = @model.new
    end

    # GET /admin/test-case/custom-fields/1/edit
    # GET /admin/test-run/custom-fields/1/edit
    def edit
      authorize! :manage, @model
      @enumerations = [@custom_field.enumeration]
    end

    # POST /admin/test-case/custom-fields
    # POST /admin/test-run/custom-fields
    def create
      authorize! :manage, @model
      @custom_field = @model.new(custom_field_params)
      respond_to do |format|
        if @custom_field.save
          notice_successfully_created(@custom_field)
          format.html { redirect_to custom_field_url(@custom_field) }
        else
          set_projects
          set_type_names
          format.html { render 'new', model_name: params[:model_name] }
        end
      end
    end

    # PATCH/PUT /admin/test-case/custom-fields/1
    # PATCH/PUT /admin/test-run/custom-fields/1
    def update
      authorize! :manage, @model
      respond_to do |format|
        if @custom_field.update(update_custom_field_params)
          notice_successfully_updated(@custom_field)
          format.html { redirect_to custom_field_url(@custom_field) }
        else
          @enumerations = [@custom_field.enumeration]
          format.html { render 'edit' }
        end
      end
    end

    # DELETE /admin/test-case/custom-fields/1
    # DELETE /admin/test-run/custom-fields/1
    def destroy
      authorize! :manage, @model
      @custom_field.save_deleted
      notice_successfully_destroyed(@custom_field)
      respond_to do |format|
        format.html { redirect_to custom_fields_url(@custom_field) }
      end
    end

    def clone
      authorize! :manage, @model
      set_custom_field
      @custom_field = @custom_field.generate_duplicate
      set_projects
      @type_name = @custom_field.type_name

      @type_names = [@type_name]
      set_enumerations
      params[:no_change_type_name] = "true"
      notice_successfully_cloned(@custom_field)
    end

    private

    # Use callbacks to share common setup or constraints between actions.
    def set_custom_field
      @custom_field = @model.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def custom_field_params
      params.require(:custom_field).permit(:name, :description, :type_name, :upper_limit, :lower_limit, :default_value, :project_id, :enumeration_id)
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def update_custom_field_params
      params.require(:custom_field).permit(:name, :description, :upper_limit, :lower_limit, :default_value, :project_id)
    end


    def set_type_names
      @type_names = @model.type_names.map(&:to_s)
    end

    def set_type_name
      @type_name = params[:type_name] || :string
    end

    def set_projects
      @projects = Tmt::Project.all
    end

    def set_enumerations
      @enumerations = ::Tmt::Enumeration.where(test_case_custom_field_id: nil, test_run_custom_field_id: nil)
    end

    def set_model_class
      if params[:model_name].to_s == "test_run"
        @model = Tmt::TestRunCustomField
      elsif params[:model_name].to_s == "test_case"
        @model = Tmt::TestCaseCustomField
      end
    end

    def custom_field_url(custom_field)
      case custom_field.class.name.downcase
      when /run/
        admin_test_run_custom_field_url(custom_field)
      when /case/
        admin_test_case_custom_field_url(custom_field)
      else

      end
    end
  end
end
