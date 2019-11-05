class Admin::MachinesController < ApplicationController
  before_action :authenticate_user!

  # GET admin/machines
  def index
    authorize! :manage, Tmt::Machine
    @users = User.undeleted.where(is_machine: true)
  end

  # GET admin/machines/new
  def new
    authorize! :create, Tmt::Machine
    @machine = Tmt::Machine.new(user_id: params[:user_id])
    @user = @machine.user
    respond_to do |format|
      format.html
      format.js { render layout: false }
    end
  end

  # GET admin/machines/1/edit
  def edit
    @machine = Tmt::Machine.find(params[:id])
    authorize! :update, Tmt::Machine
    @user = @machine.user

    respond_to do |format|
      format.html
      format.js { render layout: false }
    end
  end

  # POST admin/machines
  def create
    authorize! :create, Tmt::Machine
    @machine = Tmt::Machine.new(create_machine_params)
    @user = @machine.user
    if @machine.save
      notice_successfully_created(@machine)
      redirect_to admin_machines_url
    else
      flash.now[:alert] = @machine.errors.full_messages.join(', ')
      render 'new'
    end
  end

  # PATCH/PUT admin/machines/1
  def update
    @machine = Tmt::Machine.find(params[:id])
    authorize! :edit, @machine
    @user = @machine.user
    respond_to do |format|
      if @machine.update(machine_params)
        notice_successfully_updated(@machine)
        format.html { redirect_to admin_machines_url }
      else
        format.html { render 'edit' }
      end
    end
  end

  private

  def machine_params
    params.require(:machine).permit(:ip_address, :mac_address, :hostname, :fully_qualified_domain_name)
  end

  def create_machine_params
    params.require(:machine).permit(:user_id, :ip_address, :mac_address, :hostname, :fully_qualified_domain_name)
  end

end
