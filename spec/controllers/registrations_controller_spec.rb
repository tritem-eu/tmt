require 'spec_helper'

describe RegistrationsController do
  extend CanCanHelper
  include Devise::TestHelpers

  let(:user) { create(:user, name: "Test User") }

  before do
    @request.env["devise.mapping"] = Devise.mappings[:user]
  end

  describe "GET 'new'" do

    it "render 'new' view for no logged user" do
      get :new, controller: 'registrations', path_name: {new: 'sign_up'}
      response.should be_success
    end

    it "doesn't render 'new' view for logged user" do
      sign_in user
      get :new, controller: 'registrations', path_name: {new: 'sign_up'}
      response.should_not be_success
    end

  end

  describe "POST 'create'" do

    let(:valid_attributes) do
      {name: "Peter", email: "peter12345@example.com", password: "secret-password", password_confirmation: "secret-password"}
    end

    it "shouldn't create user when Cfgs.user_creates_account variable equals false" do
      Tmt::Cfg.first.update(user_creates_account: false)
      expect do
        post :create, path_name: {new: 'sign_up'}, user: valid_attributes
      end.to change(User, :count).by(0)
      flash[:alert].should eq("You are not authorized to access this page.")
    end

    it "should create user when Cfgs.user_creates_account variable equals true" do
      Tmt::Cfg.first.update(user_creates_account: true)
      expect do
        post :create, path_name: {new: 'sign_up'}, user: valid_attributes
      end.to change(User, :count).by(1)
      flash[:notice].should include("A message with a confirmation link has been sent to your email address.")
    end
  end

  describe "DELETE 'destroy'" do
    it "doesn't exist" do
      sign_in user
      expect do
        delete :destroy, controller: 'registrations', path_name: {new: 'sign_up'}
      end.to raise_error
      User.where(id: user.id).should have(1).item
    end
  end

  describe "PUT udpate" do
    it "User can update name" do
      sign_in user
      user.name.should eq("Test User")
      put :update, user: {name: 'admin', current_password: user.password}, path_name: {new: 'sign_up'}
      user.reload.name.should eq('admin')
    end

    it "User can update password" do
      sign_in user
      old_hash = user.encrypted_password
      put :update, user: {password: 'New password', password_confimration: 'New password', current_password: user.password}, path_name: {new: 'sign_up'}
      user.reload.encrypted_password.should_not eq(old_hash)
    end

    it "User cannot update email" do
      sign_in user
      put :update, user: {email: 'newexample@example.com', current_password: user.password}, path_name: {new: 'sign_up'}
      user.reload.email.should_not eq('newexample@example.com')
    end

  end

end
