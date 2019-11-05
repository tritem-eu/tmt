# encoding: utf-8

module Tmt
  class TestCaseVersionsController < ApplicationController
    before_action :authenticate_user!

    before_action :set_version, only: [:only_file, :show, :download, :progress]

    # GET /projects/1/test-cases/1/versions/1
    def show
      authorize! :lead, @version.test_case
      @author = @version.author
      @dispenser_executions = ::Tmt::Dispenser.new(@version.executions.order(created_at: :desc), 3, params[:executions])
      @executions = @dispenser_executions.collection
    end

    # POST /test_case_versions
    def create
      @version = Tmt::TestCaseVersion.new(test_case_version_params)
      @version.author = current_user
      @test_case = @version.test_case
      @project = @test_case.project
      authorize! :lead, @version.test_case
      authorize! :no_lock, @test_case

      respond_to do |format|
        if @version.save
          Tmt::UserActivity.save_for_version(@project, @test_case, current_user, @version)
          notice_successfully_created(@version, :also_now)
          format.js { js_redirect_to project_test_case_url(@project, @test_case) }
          format.html { redirect_to project_test_case_url(@project, @test_case) }
        else
          flash[:alert] =  t(:alert_for_create, scope: [:controllers, :test_case_versions])
          format.js { render layout: false }
          format.html { redirect_to project_test_case_url(@project, @test_case) }
        end
      end
    end

    # GET /test_case_versions/1/download
    def download
      @test_case = @version.test_case
      authorize! :lead, @test_case
      send_data @version.content, filename: "#{@version.file_name}"
    end

    # GET /test-cases/1/versions/1/only-file
    def only_file
      @test_case = @version.test_case
      authorize! :lead, @test_case
      render layout: 'file_content'
    end

    # GET /test_cases/1/versions/1/progress.js
    def progress
      authorize! :lead, @test_case
      respond_to do |format|
        format.html { redirect_to :back }
        format.js {render layout: false}
      end
    end

    private

    def test_case_version_params
      params.require(:test_case_version).permit(:test_case_id, :datafile, :comment, :execution_id)
    end

    def set_version
      @version = Tmt::TestCaseVersion.find(params[:id])
      @test_case = @version.test_case
      @project = @test_case.project
    end

  end
end
