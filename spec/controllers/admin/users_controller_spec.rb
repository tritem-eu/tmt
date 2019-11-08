require 'spec_helper'

describe Admin::UsersController do
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

  describe "GET index" do
    it_should_not_authorize(self, [:no_logged, :foreign]) do
      get :index
    end

    it "should show list all users when admin is logged in" do
      ready(admin, user)
      sign_in admin
      get :index
      assigns(:users).should match_array([admin, user])
    end
  end

  describe "GET edit_role" do
    [:html, :js].each do |format|
      it "should render view change_role for format #{format}" do
        sign_in user

        get :edit_role, :id => user.id, format: format
        render_template(:change_role)
      end
    end
  end

  describe "PUT update_role" do

    it_should_not_authorize(self, [:foreign, :no_logged]) do
      put :update_role, :id => admin.id, user: {role_ids: ['1']}
    end

    [:html, :js].each do |format|
      it "should update role of user; format #{format}" do
        sign_in admin
        admin.reload.role_ids.should eq([1, 2])
        put :update_role, :id => admin.id, user: {role_id: '1'}, format: format
        admin.reload.role_ids.should eq([1])
      end

      it "should not remove all roles for user; format #{format}" do
        sign_in admin
        user = create(:user)
        user.reload.role_ids.should eq([Role.where(name: 'user').first.id])
        put :update_role, id: user.id, format: format
        user.reload.role_ids.should_not be_empty
        response.status.should eq(302)
        flash[:alert].should match(/User's role was not updated.*/)
      end
    end
  end

  describe "GET 'new'" do

    it_should_not_authorize(self, [:foreign, :no_logged]) do
      get :new
    end

    it "render 'new' view" do
      sign_in admin
      get :new
      response.should render_template(:new)
    end

    it "assigns @user" do
      sign_in admin

      get :new
      assigns(:user).should be_a(User)
    end
  end

  describe "POST create" do
    describe "with valid params" do
      it_should_not_authorize(self, [:no_logged, :foreign]) do
        expect {
          post :create, {user: valid_attributes}
        }.to change(User, :count).by(0)
      end

      it "creates a new User when is logged admin" do
        sign_in admin
        expect {
          post :create, {user: valid_attributes}
        }.to change(User, :count).by(1)
      end

      it "creates a user with correctly data" do
        sign_in admin
        expect {
          post :create, {user: valid_attributes.merge({
            name: '20140710 1540',
            email: '20140710.1540@example.com',
            is_machine: '1',
            password: 'secret123',
            password_confirmation: 'secret123'
          })}
        }.to change(User, :count).by(1)
        user = User.last
        user.name.should eq '20140710 1540'
        user.email.should eq '20140710.1540@example.com'
        user.is_machine.should eq 1
      end


      it "redirects to the list of users" do
        sign_in admin
        post :create, {user: valid_attributes}
        response.should redirect_to(admin_users_path)
      end

    end

    describe "with invalid params" do
      before do
        sign_in admin
      end

      it "assigns a newly created but unsaved project as @project" do
        Tmt::Project.any_instance.stub(:save).and_return(false)
        post :create, {user: { "name" => "invalid value" }}
        assigns(:user).should be_a_new(User)
      end

      it "re-renders the 'new' template" do
        Tmt::Project.any_instance.stub(:save).and_return(false)
        post :create, {user: { "name" => "invalid value" }}
        response.should render_template("new")
      end

    end
  end

  describe "GET 'edit'" do

    it_should_not_authorize(self, [:foreign, :no_logged]) do
      get :edit, id: user.id
    end

    it "render 'edit' view" do
      sign_in admin
      get :edit, id: user.id
      response.should render_template(:edit)
    end

    it "assigns @user" do
      sign_in admin

      get :edit, id: user.id
      assigns(:user).should eq(user)
    end
  end

  describe "PUT update" do
    before do
      ready(user)
    end

    describe "with valid params" do

      it_should_not_authorize(self, [:no_logged, :foreign, 'self.user']) do
        ready(user)
        put :update, {:id => user.id, user: valid_attributes}
      end

      it "updates the requested project" do
        sign_in admin
        ready(user)
        User.any_instance.should_receive(:update_attributes).with({ "name" => "MyString" })
        put :update, {id: user.id, user: { "name" => "MyString" }}
      end

      it "redirects to the project" do
        sign_in admin
        put :update, {:id => user.id, user: valid_attributes}
        response.should redirect_to(admin_users_path)
      end

      it "can change password" do
        sign_in admin
        put :update, {:id => user.id, user: valid_attributes.merge(switch_password: 'true', password: 'ed765aqw', password_confirmation: 'ed765aqw')}
        user.reload.valid_password?('ed765aqw').should be true
      end

      it "can not change password" do
        sign_in admin
        put :update, {:id => user.id, user: valid_attributes.merge(switch_password: 'false', password: 'ed765aqw', password_confirmation: 'ed765aqw')}
        user.reload.valid_password?('ed765aqw').should be false
      end

    end

    describe "with invalid params" do

      it "assigns the project as @project" do
        sign_in admin
        User.any_instance.stub(:update_attributes).and_return(false)
        put :update, {:id => user.id, user: { "name" => "invalid value" }}
        assigns(:user).should eq(user)
      end

      it "re-renders the 'edit' template" do
        sign_in admin

        User.any_instance.stub(:update_attributes).and_return(false)
        put :update, {:id => user.id, :user => { "name" => "invalid value" }}
        response.should render_template("edit")
      end
    end
  end

  describe "DELETE destroy" do
    it "should not authorize for ordinary user" do
      user = create(:user)
      ready(admin)
      sign_in user
      admin.deleted_at.should be_nil
      delete :destroy, {:id => user.id}
      admin.reload.deleted_at.should be_nil
      flash.alert.should eq("Not authorized as an administrator")
      response.should redirect_to(root_url)
    end

    it "should set deleted_at attribut for destroyed user" do
      sign_in admin
      user = create(:user)
      user.deleted_at.should be_nil
      delete :destroy, {:id => user.id}
      user.reload.deleted_at.should_not be_nil
      flash.notice.should eq("User was successfully destroyed")
      response.should redirect_to(admin_users_url)
    end

    it "should not set deleted_at attribut for itself" do
      sign_in admin
      admin.deleted_at.should be_nil
      delete :destroy, {id: admin.id}
      admin.reload.deleted_at.should be_nil
      flash.alert.should eq("You cannot delete yourself")
      response.should redirect_to(admin_users_url)
    end
  end
end
