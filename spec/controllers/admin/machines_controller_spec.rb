require 'spec_helper'

describe Admin::MachinesController do
  extend CanCanHelper

  let(:john) { create(:user, is_machine: false) }
  let(:windows) do
    user = create(:user, is_machine: true, deleted_at: Time.now)
  end

  let(:ubuntu) do
    user = create(:user, is_machine: true)
    Tmt::Machine.create(user_id: user.id, ip_address: '127.0.0.1')
    user
  end

  let(:machine) do
    ubuntu.machine
  end

  let(:linux_mint) do
    create(:user, is_machine: true)
  end

  let(:admin) { create(:admin) }

  describe "GET index" do
    before do
      ready(admin, john, ubuntu, linux_mint, windows)
    end

    it_should_not_authorize(self, [:no_logged, :foreign]) do
      get :index
    end

    it "assigns users as @users" do
      sign_in admin
      get :index
      assigns(:users).should eq([ubuntu, linux_mint])
    end
  end

  describe "GET new" do
    before do
      ready(admin, john, ubuntu, linux_mint, windows)
    end

    it_should_not_authorize(self, [:no_logged, :foreign]) do
      get :new, {:user_id => linux_mint.id}
    end

    [:html, :js].each do |format|
      it "assigns the requested machine as @machine for format #{format}" do
        sign_in admin
        get :new, user_id: linux_mint.id, format: format
        correct_attributes = ::Tmt::Machine.new(user: linux_mint).attributes
        assigns(:machine).attributes.should eq correct_attributes
      end
    end
  end

  describe "GET edit" do
    it_should_not_authorize(self, [:no_logged, :foreign]) do
      get :edit, id: ubuntu.machine.id
    end

    [:html, :js].each do |format|
      it "assigns the requested machine as @machine for format #{format}" do
        sign_in admin
        machine = ubuntu.machine
        get :edit, id: machine.id, format: format
        assigns(:machine).should eq(machine)
      end
    end
  end

  describe "POST create" do
    describe "with valid params" do
      let(:valid_attributes) do
        Tmt::Machine.new(user_id: linux_mint.id, ip_address: '127.0.0.1').attributes
      end

      it_should_not_authorize(self, [:no_logged, :foreign]) do
        post :create, :machine => valid_attributes
      end

      [:html, :js].each do |format|
        it "creates a new Machine for format #{format}" do
          sign_in admin
          expect {
            post :create, :machine => valid_attributes, format: format
          }.to change(Tmt::Machine, :count).by(1)
        end

      end

      it "redirects to the created machine" do
        sign_in admin
        post :create, :machine => valid_attributes
        response.should redirect_to(admin_machines_path)
        response.status.should eq 302
      end

    end

    describe "with invalid params" do
      it "assigns a newly created but unsaved machine as @machine" do
        sign_in admin
        # Trigger the behavior that occurs when invalid params are submitted
        Tmt::Machine.any_instance.stub(:save).and_return(false)
        post :create, machine: {user_id: linux_mint.id}
        assigns(:machine).should be_a_new(Tmt::Machine)
      end

      it "re-renders the 'new' template" do
        sign_in admin
        Tmt::Machine.any_instance.stub(:save).and_return(false)
        post :create, machine: {user_id: linux_mint.id}
        response.should render_template("new")
        response.status.should eq 200
      end
    end
  end
  describe "PUT update" do
    describe "with valid params" do
      let(:valid_attributes) do
        {ip_address: '127.0.0.1', mac_address: 'ff:ff:ff:ff:ff:ff'}
      end

      it_should_not_authorize(self, [:no_logged, :foreign]) do
        put :update, {:id => machine.id, :machine => valid_attributes}
      end

      it "updates the requested machine" do
        sign_in admin
        machine.mac_address.should be_nil
        put :update, {:id => machine.id, :machine => valid_attributes}
        machine.reload.mac_address.should eq 'ff:ff:ff:ff:ff:ff'
      end

      it "assigns the requested machine as @machine" do
        sign_in admin
        put :update, {:id => machine.id, :machine => valid_attributes}
        assigns(:machine).should eq(machine)
      end

      it "redirects to the machines" do
        sign_in admin
        put :update, {:id => machine.id, :machine => valid_attributes}
        response.should redirect_to(admin_machines_path)
        response.status.should eq 302
      end
    end

    describe "with invalid params" do
      let(:invalid_attributes) do
        {ip_address: 'invalid'}
      end

      it "assigns the machine as @machine" do
        sign_in admin
        Tmt::Machine.any_instance.stub(:update).and_return(false)
        put :update, {:id => machine.id, :machine => invalid_attributes}
        assigns(:machine).should eq machine
        assigns(:user).should eq machine.user
        response.status.should eq 200
      end

      it "re-renders the 'edit' template" do
        sign_in admin
        Tmt::Machine.any_instance.stub(:update).and_return(false)
        put :update, {id: machine.id, machine: invalid_attributes}
        response.should render_template("edit")
      end
    end
  end
end
