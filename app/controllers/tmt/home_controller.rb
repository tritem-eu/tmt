class Tmt::HomeController < ApplicationController

  def index
    @projects = ::Tmt::Project.user_projects(current_user)
  end

end
