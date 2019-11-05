module Admin
  class TestCaseTypesController < ApplicationController
    before_action :authenticate_user!

    before_action :set_test_case_type, only: [:show, :edit, :update, :destroy]

    # GET /admin/test-case-types
    def index
      authorize! :lead, Tmt::TestCaseType
      @test_case_types = Tmt::TestCaseType.undeleted
    end

    # GET /admin/test-case-types/1
    def show
      authorize! :read, Tmt::TestCaseType
      respond_to do |format|
        format.html
        format.js { render layout: false }
      end
    end

    # GET /admin/test-case-types/new
    def new
      authorize! :lead, Tmt::TestCaseType
      @test_case_type = Tmt::TestCaseType.new
    end

    # GET /admin/test_case_types/1/edit
    def edit
      authorize! :lead, Tmt::TestCaseType
    end

    # POST /admin/test-case-types
    def create
      authorize! :lead, Tmt::TestCaseType
      @test_case_type = Tmt::TestCaseType.new(test_case_type_params)

      respond_to do |format|
        if @test_case_type.save
          notice_successfully_created(@test_case_type)
          format.html { redirect_to admin_test_case_types_url }
        else
          format.html { render 'new' }
        end
      end
    end

    # PATCH/PUT /admin/test-case-types/1
    def update
      authorize! :lead, Tmt::TestCaseType
      respond_to do |format|
        if @test_case_type.update(test_case_type_params)
          notice_successfully_updated(@test_case_type)
          format.html { redirect_to admin_test_case_types_url }
        else
          format.html { render 'edit' }
        end
      end
    end

    # DELETE /admin/test-case-types/1
    def destroy
      authorize! :lead, Tmt::TestCaseType
      @test_case_type.set_deleted
      notice_successfully_destroyed(@test_case_type)
      respond_to do |format|
        format.html { redirect_to admin_test_case_types_url }
      end
    end

    private

    # Use callbacks to share common setup or constraints between actions.
    def set_test_case_type
      @test_case_type = Tmt::TestCaseType.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def test_case_type_params
      params.require(:test_case_type).permit(:name, :has_file, :extension, :converter)
    end
  end
end
