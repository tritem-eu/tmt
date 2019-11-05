class Admin::ProjectsController < ApplicationController
  before_action :authenticate_user!

  before_action :set_project, only: [:edit, :update]
  before_action :set_test_case_types, only: [:edit, :update, :new, :create]

  # GET admin/projects
  def index
    authorize! :lead, Tmt::Project
    @projects = Tmt::Project.all
  end

  # GET admin/projects/new
  def new
    authorize! :lead, Tmt::Project

    @project = Tmt::Project.new
    respond_to do |format|
      format.html
      format.js { render layout: false }
    end
  end

  # GET admin/projects/1/edit
  def edit
    authorize! :lead, Tmt::Project
    @project_name = @project.name
    respond_to do |format|
      format.html
      format.js { render layout: false }
    end
  end

  # POST admin/projects
  def create
    authorize! :lead, Tmt::Project

    @project = Tmt::Project.new(project_params)
    @project.creator = current_user

    if @project.save
      notice_successfully_created(@project)
      redirect_to admin_projects_url
    else
      render 'new'
    end
  end

  # PATCH/PUT admin/projects/1
  def update
    authorize! :lead, Tmt::Project
    @project_name = @project.name

    respond_to do |format|
      if @project.update(project_params)
        notice_successfully_updated(@project)
        format.html { redirect_to admin_projects_url }
      else
        format.html { render 'edit' }
      end
    end
  end

  private

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
