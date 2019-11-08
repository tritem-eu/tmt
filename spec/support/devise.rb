# This support package contains modules for authenticaiting
# devise users for request specs.

# http://rawlins.weboffins.com/2013/03/22/request-and-controller-specs-with-devise/
# This module authenticates users for request specs.#
module ValidUserRequestHelper
  def sign_in(user = nil)
    @user ||= user
    sign_in_as_a_valid_user
  end

  # Define a method which signs in as a valid user.
  def sign_in_as_a_valid_user
    # ASk factory girl to generate a valid user for us.
    @user ||= create :user
    # We action the login request using the parameters before we begin.
    # The login requests will match these to the user we just created in the factory, and authenticate us.
    visit new_user_session_path
    within("#new_user") do
      fill_in "user_email", :with => @user.email
      fill_in "user_password", :with => @user.password
      find("input[type='submit']").click
    end
    #post_via_redirect user_session_path, 'user[email]' => @user.email, 'user[password]' => @user.password
  end

end

# Configure these to modules as helpers in the appropriate tests.
RSpec.configure do |config|
  # Include the help for the request specs.
  config.include ValidUserRequestHelper, :type => :feature
  config.include Devise::TestHelpers, :type => :controller
end
