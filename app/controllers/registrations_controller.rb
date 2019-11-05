class RegistrationsController < Devise::RegistrationsController
  def create
    if false == ::Tmt::Cfg.first.user_creates_account
      authorize! :user, nil
    end
    super
  end
end
