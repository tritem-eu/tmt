module Admin
  class UsersController < ApplicationController
    before_action :authenticate_user!

    # GET /admin/users
    def index
      authorize! :list, current_user
      @users = User.all
    end

    # GET /users/1
    def show
      @user = User.find(params[:id])
      @machine = @user.machine
    end

    # GET /admin/users/1/edit-role
    def edit_role
      authorize! :update_role, current_user
      @user = User.find(params[:id])

      respond_to do |format|
        format.html
        format.js { render layout: false}
      end
    end

    # PUT /admin/users/1/edit-role
    def update_role
      authorize! :update_role, current_user
      @user = User.find(params[:id])
      params[:user] ||= {role_id: nil}
      if @user.change_role(params[:user][:role_id])
        redirect_to admin_users_url, :notice => t(:notice_for_update_role, scope: [:controllers, :users])
      else
        redirect_to admin_users_url, :alert => t(:alert_for_update_role, scope: [:controllers, :users])
      end
    end

    # GET /admin/users/1/edit
    def edit
      authorize! :create, current_user
      @user = User.find(params[:id])
    end

    # PUT /admin/users/1
    def update
      authorize! :update, current_user
      @user = User.find(params[:id])
      if @user.update_attributes(update_params_permit)
        notice_successfully_updated(@user)
        redirect_to admin_users_url
      else
        render :edit, alert: t(:alert_for_update, scope: [:controllers, :users])
      end
    end

    # GET /admin/users/new
    def new
      authorize! :create, current_user
      @user = User.new
    end

    # POST /admin/users
    def create
      authorize! :create, current_user
      @user = User.new params_permit
      if @user.save
        @user.confirm!
        @user.add_role :user
        notice_successfully_created(@user)
        redirect_to admin_users_url
      else
        render 'new'
      end
    end

    # DELETE /admin/users/1
    def destroy
      authorize! :destroy, current_user, :message => t(:message_for_destroy, scope: [:controllers, :users])
      user = User.find(params[:id])

      unless user.eql?(current_user)
        user.update(deleted_at: Time.now)
        notice_successfully_destroyed(user)
        redirect_to admin_users_url
      else
        redirect_to admin_users_url, :alert => t(:alert_for_destroy, scope: [:controllers, :users])
      end
    end

    private

    def params_permit
      params.require(:user).permit(:name, :email, :is_machine, :password, :password_confirmation)
    end

    def update_params_permit
      if params[:user] and params[:user][:switch_password] == 'true'
        params.require(:user).permit(:name, :email, :is_machine, :switch_password, :password, :password_confirmation)
      else
        params.require(:user).permit(:name, :email, :is_machine, :switch_password)
      end
    end
  end
end
