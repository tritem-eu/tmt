class SessionsController < Devise::SessionsController
  protected

  def after_sign_in_path_for(resource)
    if resource.is_a?(User) && resource.deleted? #resource.banned?
      sign_out resource
      flash.delete(:notice)
      flash[:alert] = "This account has been deleted by an admin."
      root_path
    else
      super
    end
  end
end
