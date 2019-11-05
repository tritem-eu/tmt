class Tmt::SetsController < ApplicationController
  before_action :authenticate_user!

  before_action :set_set, only: [:show, :edit, :update, :destroy, :download]
  before_action :set_project

  # GET /project/1/sets
  # GET /project/1/sets.json
  def index
    @project = Tmt::Project.find(params[:project_id])
    authorize! :member, @project
    if params[:test_run_id]
      @test_run = ::Tmt::TestRun.find(params[:test_run_id])
      @test_run = nil unless @test_run.project == @project
    end
    @member = current_user.member_for_project(@project)
    @member.set_nav_tab(:test_case, :tree) if @member
    @sets = Tmt::Set.includes(:children).where(project_id: @project.id, parent_id: nil)
    @search = Tmt::TestCaseSearcher.new(
      project: @project,
      user: current_user,
      params: params,
      controller: self
    )
    @test_cases = @search.with_filter
    @hash_tree = Tmt::Set.hash_tree(@project, @search.without_filter)
    set_set_ids
  end

  # GET /projects/1/sets/new
  def new
    @set = Tmt::Set.new(project: @project)
    authorize! :lead, @set
    @parent = Tmt::Set.find(params[:parent_id]) if params[:parent_id]
    respond_to do |format|
      format.html
      format.js { render layout: false }
    end
  end

  # GET /pojects/1/sets/1/edit
  def edit
    @set = Tmt::Set.find(params[:id])
    authorize! :lead, @set

    @project = @set.project
    @sets = @set.sets_for_select

    respond_to do |format|
      format.html
      format.js { render layout: false }
    end
  end

  # POST /projects/1/sets
  def create
    @set = Tmt::Set.new(set_params)
    @set.project = @project
    authorize! :lead, @set
    @sets = Tmt::Set.where(project_id: @project.id, parent_id: nil)

    respond_to do |format|
      if @set.save
        @test_cases = Tmt::TestCase.undeleted.where(project: @project)
        set_set_ids
        @hash_tree = Tmt::Set.hash_tree(@project, @test_cases)
        notice_successfully_created(@set, :also_now)
        format.html { redirect_to project_sets_url(@project) }
        format.js { render layout: false }
      else
        @sets = @project.sets
        format.html { render 'new' }
        format.js { render 'new' }
      end
    end
  end

  # PATCH/PUT /projects/1/sets/1
  def update
    @project = @set.project
    authorize! :lead, @set
    @member = ::Tmt::Member.where(project: @project, user: current_user).first_or_create
    @set_ids = @member.set_ids

    respond_to do |format|
      if @set.update(set_params)
        notice_successfully_updated(@set, :also_now)
        format.html { redirect_to project_sets_url(@project)}
        format.js {render layout: false}
      else
        @sets = @set.sets_for_select
        format.html { render 'edit' }
        format.js { render 'edit' }
      end
      @test_cases = Tmt::TestCase.undeleted.where(project: @project)
      set_set_ids
      @hash_tree = Tmt::Set.hash_tree(@project, @test_cases)
    end
  end

  # DELETE /projects/1/sets/1
  def destroy
    authorize! :destroy, @set
    @set.destroy
    @test_cases = Tmt::TestCase.undeleted.where(project: @project)
    @hash_tree = Tmt::Set.hash_tree(@project, @test_cases)
    @member = ::Tmt::Member.where(project: @project, user: current_user).first_or_create
    @set_ids = @member.set_ids
    set_set_ids

    respond_to do |format|
      notice_successfully_destroyed(@set, :also_now)
      format.html { redirect_to project_sets_url(@project) }
      format.js { render layout: false }
    end
  end

  # GET projects/1/sets/1/download
  # application/octet-stream - google standard
  def download
    authorize! :lead, @set
    send_data @set.generate_zip, filename: "#{@set.name}.zip", type: 'application/octet-stream'
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_set
    @set = Tmt::Set.find(params[:id])
  end

  def set_set_ids
    if current_member
      @member = current_member
      @set_ids = []
      sets = Tmt::Set.where(project: @project)
      @set_ids = current_member.updated_set_ids(sets, params)
    end
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def set_params
    params.require(:set).permit(:name, :parent_id)
  end

  def set_project
    @project = Tmt::Project.find(params[:project_id])
  end
end
