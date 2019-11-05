class Tmt::TestCasesController < ApplicationController
  before_action :authenticate_user!

  before_action :set_test_case, only: [:show, :edit, :update, :destroy, :toggle_steward]
  before_action :set_project, only: [:index, :new, :create]
  before_render :save_current_project, only: [:show]

  # GET /projects/1/test_cases/
  def index
    authorize! :member, @project
    @member = current_user.member_for_project(@project)
    @member.set_nav_tab(:test_case, :flat) if @member
    @search = Tmt::TestCaseSearcher.new(
      project: @project,
      user: current_user,
      params: params,
      controller: self
    )
    @test_cases = @search.with_filter
  end

  # GET /projects/1/test_cases/1
  # GET /projects/1/test_cases/1.json
  def show
    authorize! :lead, @test_case
    @project = @test_case.project
    @test_case.reload_custom_field_values

    versions = Tmt::TestCaseVersion.where(test_case_id: @test_case.id).order(created_at: :desc)
    @dispenser_versions = ::Tmt::Dispenser.new(versions, 3, params[:versions])
    @versions = @dispenser_versions.collection

    @dispenser_executions = ::Tmt::Dispenser.new(@test_case.executions.order(created_at: :desc), 3, params[:executions])
    @executions = @dispenser_executions.collection

    @version = @versions.first
    @new_version = Tmt::TestCaseVersion.new(test_case: @test_case, author: current_user)
    @test_case_id = @test_case.id
    respond_to do |format|
      format.html
      format.js { render layout: false }
    end
  end

  # GET /projects/1/test_cases/new
  def new
    @test_case = Tmt::TestCase.new(project_id: @project.id)
    authorize! :member, @project
    @test_case.reload_custom_field_values
    @test_case.versions.new

    respond_to do |format|
      format.html
      format.js {render layout: false}
    end
  end

  # GET /projects/1/test_cases/1/edit
  def edit
    authorize! :lead, @test_case
    @project = @test_case.project
    @test_case.set_locked
    @test_case.reload_custom_field_values
  end

  def toggle_steward
    authorize! :lead, @test_case
    authorize! :no_lock, @test_case
    if @test_case.steward_id.nil?
      @test_case.update(steward_id: current_user.id)
    else
      @test_case.update(steward_id: nil)
    end
    redirect_to project_test_case_url(params[:project_id], @test_case)
  end

  # POST /projects/1/test_cases
  # POST /projects/1/test_cases.json
  def create
    @test_case = Tmt::TestCase.new(test_case_params)
    @test_case.creator = current_user
    @test_case.project = @project
    authorize! :lead, @test_case
    @test_case.set_steward_id_if(params, current_user)
    @test_case.reload_custom_field_values(test_case_params[:custom_field_values])
    version = nil
    if @test_case.versions.any?
      version = @test_case.versions.first
      version.author = current_user
      version.new_test_case = @test_case

      if version.datafile.blank? and version.comment.blank?
        @test_case.versions.delete_all
      end
    end

    respond_to do |format|
      if @test_case.save
        format.html do
          notice_successfully_created(@test_case)
          redirect_to project_test_case_url(@project, @test_case)
        end
        format.js {
          render layout: false
        }
      else
        if version
          @test_case.versions += [version]
        else
          @test_case.versions.new
        end
        format.html { render 'new' }
        format.js { render layout: false }
      end
    end
  end

  # PATCH/PUT /projects/1/test_cases/1
  # PATCH/PUT /projects/1/test_cases/1.json
  def update
    authorize! :lead, @test_case
    authorize! :no_lock, @test_case
    @project = @test_case.project
    @test_case.set_steward_id_if(params, current_user)
    @test_case.reload_custom_field_values

    respond_to do |format|
      if @test_case.update(update_test_case_params)
        notice_successfully_updated(@test_case)
        format.html { redirect_to project_test_case_url(@project, @test_case) }
      else
        format.html { render 'edit' }
        format.js { render layout: false }
      end
    end
  end

  # DELETE /projects/1/test_cases/1
  # DELETE /projects/1/test_cases/1.json
  def destroy
    authorize! :lead, @test_case
    authorize! :no_lock, @test_case
    @project = @test_case.project
    @test_case.set_deleted
    Tmt::UserActivity.save_for_deleted_observable(@project, @test_case, current_user)
    notice_successfully_destroyed(@test_case)
    redirect_to back_or_customize_url(
      @test_case, project_test_cases_url(@project)
    )
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_test_case
    @test_case = Tmt::TestCase.find(params[:id])
  end

  # In this place system should set current browsing test_case_id
  def save_current_project
    if current_user
      if not @test_case.nil? and @test_case.id
        project = @test_case.project
        if project
          if not current_user.current_project_id == project.id
            current_user.update(current_project: project)
          end
          member = Tmt::Member.where(project: project, user: current_user).first
          if not member.nil? and not member.current_test_case_id == @test_case.id
            member.update(current_test_case_id: @test_case.id) if member
          end
        end
      end
    end
  end

  def test_case_params
    params.require(:test_case).permit(:name, :description, :type_id, :custom_field_values => [:value], versions_attributes: [:comment, :datafile] )
  end

  def update_test_case_params
    params.require(:test_case).permit(:name, :description, :custom_field_values => [:value])
  end

  def set_project
    @project = Tmt::Project.where(id: params[:project_id]).last
  end

end
