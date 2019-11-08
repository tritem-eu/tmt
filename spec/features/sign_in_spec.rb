require 'spec_helper'

#In order to get access to protected sections of the site
#A user
#Should be able to sign in
feature "Sign in" do
  scenario "User is not signed up" do
    @user = create(:user)
    @user.destroy

    sign_in_as_a_valid_user
    page.should have_selector "#flash_alert", text: "Invalid email or password."
    expect(page.current_url).to eq(new_user_session_url)
  end

  scenario "User cannot sign in when is deleted" do
    @user = create(:user)
    @user.update(deleted_at: Time.now)

    sign_in_as_a_valid_user
    page.should have_selector "#flash_alert", text: "This account has been deleted by an admin."
    expect(page.current_url).to eq(root_url)
  end

  scenario "User has not confirmed account" do
    @user = create(:user, confirmed_at: nil)

    sign_in_as_a_valid_user
    page.should have_selector "#flash_alert", text: "You have to confirm your account before continuing."
    expect(page.current_url).to eq(new_user_session_url)
  end

  scenario "User signs in successfully" do
    @user = create(:user)

    sign_in_as_a_valid_user
    page.should have_selector "#flash_notice", text: "Signed in successfully."
    expect(page.current_url).to eq(root_url)
  end

  scenario "User enters wrong email" do
    @user = create(:user)
    @user.email = "wrong_email"

    sign_in_as_a_valid_user
    page.should have_selector "#flash_alert", text: "Invalid email or password."
    expect(page.current_url).to eq(new_user_session_url)
  end

  scenario "User enters wrong password" do
    @user = create(:user)
    @user.password = "wrong_password"

    sign_in_as_a_valid_user
    page.should have_selector "#flash_alert", text: "Invalid email or password."
    expect(page.current_url).to eq(new_user_session_url)
  end
end
