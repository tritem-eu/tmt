class Tmt::ProjectsController < ApplicationController
  before_action :authenticate_user!

  before_action :set_project, only: [:show]
  before_render :save_current_project, only: [:show]

  # GET /projects/1
  # GET /projects/1.json
  def show
    authorize! :member, @project
    current_user.visited_project(@project.id)
    @campaign = @project.open_campaign
    @test_cases = @project.undeleted_test_cases
    @test_runs = @project.undeleted_test_runs
    @test_case_graph = ::Tmt::TestCase.for_graph(:updated_at_last_month, test_cases: @test_cases)
    @test_run_graph = ::Tmt::TestRun.for_graph(:execution_last_month, test_runs: @test_runs)
    @test_runs = @test_runs.first(5)
    @test_cases = @test_cases.first(5)

    respond_to do |format|
      format.html
      format.js { render layout: false }
    end
  end

  private

  # In this place system should set current browsing test_run_id
  def save_current_project
    current_user.update(current_project: @project) if current_user
  end

  # set project
  def set_project
    @project = Tmt::Project.find(params[:id])
  end

  # set list active test case types
  def set_test_case_types
    @test_case_types = Tmt::TestCaseType.undeleted
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def project_params
    params.require(:project).permit(:name, :description, :default_type_id)
  end
end
