module Tmt
  class UsersController < ApplicationController
    before_action :authenticate_user!

    # GET /users/1
    def show
      @user = User.find(params[:id])
      @machine = @user.machine
    end
  end
end
