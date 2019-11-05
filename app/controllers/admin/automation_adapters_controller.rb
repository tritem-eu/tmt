class Admin::AutomationAdaptersController < ApplicationController
  before_action :authenticate_user!

  # GET admin/automation-adapters
  def index
    authorize! :manage, Tmt::AutomationAdapter
    @adapters = Tmt::AutomationAdapter.all
  end

  # GET admin/automation-adapters/new
  def new
    authorize! :create, Tmt::AutomationAdapter
    @adapter = Tmt::AutomationAdapter.new
    respond_to do |format|
      format.html
      format.js { render layout: false }
    end
  end

  # POST admin/automation-adapters
  def create
    authorize! :create, Tmt::AutomationAdapter
    @adapter = Tmt::AutomationAdapter.new(adapter_params)
    if @adapter.save
      notice_successfully_created(@adapter)
      redirect_to admin_automation_adapters_url
    else
      flash.now[:alert] = @adapter.errors.full_messages.join(', ')
      render 'new'
    end
  end

  # GET admin/automation-adapters/1/edit
  def edit
    authorize! :update, Tmt::Machine
    @adapter = Tmt::AutomationAdapter.find(params[:id])
    respond_to do |format|
      format.html
      format.js { render layout: false }
    end
  end

  # PATCH/PUT admin/automation-adapters/1
  def update
    authorize! :edit, Tmt::Machine
    @adapter = Tmt::AutomationAdapter.find(params[:id])
    respond_to do |format|
      if @adapter.update(adapter_params)
        notice_successfully_updated(@adapter)
        format.html { redirect_to admin_automation_adapters_url }
      else
        format.html { render 'edit' }
      end
    end
  end

  private

  def adapter_params
    params.require(:automation_adapter).permit(:project_id, :user_id, :name, :adapter_type, :polling_interval, :description)
  end

end
