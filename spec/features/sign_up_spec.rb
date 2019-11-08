require 'spec_helper'

# In order to get access to protected sections of the site
# As a user
# I want to be able to sign up
feature "Sign up when user_creates_account option is active" do

  before do
    Tmt::Cfg.first.update(user_creates_account: true)
    visit '/users/sign_out'
  end

  scenario "User signs up" do
    visit '/users/new'
    page.should_not have_content('Ask your admin to create Your account')
    page.should have_css('form.new_user')
  end

  scenario "User signs up with valid data" do
    visit '/users/new'
    fill_in "Name", :with => "UserName"
    fill_in "Email", :with => "username@example.com"
    fill_in "user_password", :with => "password"
    fill_in "user_password_confirmation", :with => "password"
    click_button "Sign up"

    page.should have_content "A message with a confirmation link has been sent to your email address. Please open the link to activate your account."
  end

  scenario "User signs up with invalid email" do
    visit '/users/new'
    fill_in "Name", :with => "UserName"
    fill_in "Email", :with => "user"
    fill_in "user_password", :with => "password"
    fill_in "user_password_confirmation", :with => "password"
    click_button "Sign up"

    page.should have_content "Email is invalid Name Email"
  end

  scenario "User signs up without password" do
    visit '/users/new'
    fill_in "Name", :with => "UserName"
    fill_in "Email", :with => "username@example.com"
    fill_in "user_password", :with => ""
    fill_in "user_password_confirmation", :with => "password"
    click_button "Sign up"

    page.should have_content "Password can't be blank"
  end

  scenario "User signs up without password confirmation" do
    visit '/users/new'
    fill_in "Name", :with => "UserName"
    fill_in "Email", :with => "username@example.com"
    fill_in "user_password", :with => "password"
    fill_in "user_password_confirmation", :with => ""
    click_button "Sign up"

    page.should have_content "Password confirmation doesn't match"
  end

  scenario "User signs up with mismatched password and confirmation" do
    visit '/users/new'
    fill_in "Name", :with => "UserName"
    fill_in "Email", :with => "username@example.com"
    fill_in "user_password", :with => "password"
    fill_in "user_password_confirmation", :with => "password2"
    click_button "Sign up"

    page.should have_content "Password confirmation doesn't match"
  end
end

feature "Sign up when user_creates_account option is inactive" do

  before do
    Tmt::Cfg.first.update(user_creates_account: false)
    visit '/users/sign_out'
  end

  scenario "User signs up with valid data" do
    visit '/users/new'
    page.should have_content 'Ask your admin to create Your account'
    page.should_not have_content 'Password'
    page.should_not have_content 'Password confirmation'
    page.should_not have_css 'form.new_user'
  end
end
