require 'spec_helper'

describe Admin::MembersController do
  extend CanCanHelper

  let(:user) { create(:user) }
  let(:admin) do
    user = create(:user)
    user.add_role(:admin)
    user
  end

  let(:valid_attributes) { { project_id: project.id,  user_id: user.id} }
  let(:member) { Tmt::Member.create! valid_attributes }
  let(:project) { create(:project) }

  before do
    project
  end

  describe "GET index" do
    it_should_not_authorize(self, [:foreign, :no_logged, 'self.user']) do
      ready(member)
      get :index
    end

    it "assigns only projects and members when pojects is empty" do
      Tmt::Project.delete_all
      sign_in admin
      get :index
      response.should render_template('index')
      assigns(:projects).should be_empty
      assigns(:members).should be_empty
    end

    it "assigns all projects, member_ids and members" do
      sign_in admin
      ready(member)
      get :index
      response.should render_template('index')
      assigns(:projects).should eq([project])
      assigns(:members).should eq([member])
      assigns(:users).should include(admin)
      assigns(:project_id).should eq(project.id)
      assigns(:members_with_objects).should be_a(Hash)
    end
  end

  describe "POST create" do
    describe "with valid params" do
      it_should_not_authorize(self, [:foreign, :no_logged, 'self.user']) do
        post :create, {:member => valid_attributes}
      end

      it "creates a new ProjectMember" do
        sign_in admin
        post :create, {member: valid_attributes}
        ::Tmt::Member.where(valid_attributes).first.is_active.should be true
      end

      it "should set status on active when ProjectMember object has got set inactive" do
        sign_in admin
        member = ::Tmt::Member.create(valid_attributes)
        member.update(is_active: false)
        member.reload.is_active.should be false
        post :create, {member: valid_attributes}
        member.reload.is_active.should be true
      end

      it "assigns a newly created member as @member" do
        sign_in admin
        post :create, {member: valid_attributes}
        assigns(:member).should be_a(Tmt::Member)
        assigns(:member).should be_persisted
      end

      it "redirects to the created member" do
        sign_in admin
        post :create, {:member => valid_attributes}
        project_id = valid_attributes[:project_id]
        response.should redirect_to(admin_members_path(project_id: project_id))
      end
    end

    describe "with invalid params" do
      it "assigns a newly created but unsaved member as @member" do
        sign_in admin
        # Trigger the behavior that occurs when invalid params are submitted
        Tmt::Member.any_instance.stub(:save).and_return(false)
        post :create, {:member => { "project" => "invalid value" }}
        assigns(:member).should be_a_new(Tmt::Member)
      end

      it "re-renders the 'new' template" do
        sign_in admin
        Tmt::Member.any_instance.stub(:save).and_return(false)
        post :create, {:member => { "project" => "invalid value" }}
        response.should redirect_to(admin_members_url)
      end
    end
  end

  describe "DELETE destroy" do
    before do
      ready(member)
    end

    it_should_not_authorize(self, [:foreign, :no_logged]) do
      delete :destroy, {:id => member.to_param}
    end

    it "destroys the requested member" do
      sign_in admin
      member.update(is_active: true)
      member.reload.is_active.should be true
      delete :destroy, {:id => member.to_param}
      member.reload.is_active.should_not be true
    end

    it "redirects to the members list" do
      sign_in admin
      delete :destroy, {:id => member.to_param}
      response.should redirect_to(admin_members_url(project_id: project.id))
    end
  end

end
