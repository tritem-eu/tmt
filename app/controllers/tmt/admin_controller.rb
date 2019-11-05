module Tmt
  class AdminController < ApplicationController
    before_action :authenticate_user!

    # GET /admin
    def show
      authorize! :manage, Tmt::Cfg
    end

  end
end
