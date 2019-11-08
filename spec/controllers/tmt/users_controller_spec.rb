require 'spec_helper'

describe Tmt::UsersController do
  extend CanCanHelper

  let(:user) { create(:user) }

  let(:admin) { create(:admin) }

  let(:valid_attributes) do
    {
      name: 'example',
      email: 'ex.ample@example.com',
      password: 'password',
      password_confirmation: 'password'
    }
  end

  describe "GET 'show'" do

    it_should_not_authorize(self, [:no_logged]) do
      get :show, :id => user.id
    end

    it "controller should render view (config.render_views)" do
      sign_in user

      get :show, :id => user.id
      response.body.should match(/html/)
    end

    it "should be successful" do
      sign_in user
      get :show, :id => user.id
      response.should be_success
    end

    it "should find the right user" do
      sign_in user

      get :show, :id => user.id
      assigns(:user).should == user
    end
  end

end
