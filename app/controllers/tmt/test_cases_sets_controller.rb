class Tmt::TestCasesSetsController < ApplicationController
  before_action :authenticate_user!

  # GET /projects/1/test-cases-sets/new
  def new
    @project = Tmt::Project.find(params[:project_id])
    @test_cases = Tmt::TestCase.where(project_id: params[:project_id])
    @set = Tmt::Set.where(id: params[:set_id]).first
    authorize! :member, @project
    @test_cases_set = Tmt::TestCasesSets.new
    set_set_ids
  end

  # POST /projects/1/test-cases-sets
  def create
    @set = Tmt::Set.where(id: params[:set_id]).first
    if @set
      @project = @set.project
      @test_case_set = Tmt::TestCasesSets.new(test_case_id: params[:test_case_id], set_id: @set.id)
      authorize! :lead, @set
      @test_case_set.save
      @sets = Tmt::Set.where(project_id: @project.id, parent_id: nil)
      set_set_ids
      @test_cases = Tmt::TestCase.undeleted.where(project: @project)
      @hash_tree = Tmt::Set.hash_tree(@project, @test_cases)

      respond_to do |format|
        message = t(:notice_for_create, scope: [:controllers, :test_cases_sets])
        format.html { redirect_to project_sets_url(@project), notice: message }
        format.js { flash.now[:notice] = message; render layout: false }
      end
    else
      respond_to do |format|
        message = t(:alert_for_create, scope: [:controllers, :test_cases_sets])
        format.html { redirect_to project_sets_url(@project), alert: message}
        format.js { flash.now[:alert] = message; render layout: false }
      end
    end
  end

  # DELETE /projects/1/test-cases-sets/1
  def destroy
    @test_cases_set = Tmt::TestCasesSets.find(params[:id])
    @set = @test_cases_set.set
    @project = @set.project
    authorize! :lead, @set
    @test_cases_set.destroy
    respond_to do |format|
      message = t(:notice_for_destroy, scope: [:controllers, :test_cases_sets])
      flash[:notice] = message
      format.html { redirect_to project_sets_url(@project), notice: message}
      format.js {
        flash.now[:notice] = message
        js_redirect_to project_sets_url(@project)
      }
    end
  end

  private

  def set_set_ids
    sets = Tmt::Set.where(project: @project)
    @set_ids = current_member.updated_set_ids(sets, {add_set_id: @set.id})
  end
end
