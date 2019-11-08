require 'spec_helper'

describe Admin::AutomationAdaptersController do
  extend CanCanHelper

  let(:admin) { create(:admin) }
  let(:oliver) { create(:user, name: 'Oliver') }
  let(:project) { create(:project) }

  let(:adapter_for_linux) { create(:automation_adapter, name: 'Linux OS') }
  let(:adapter_for_windows) { create(:automation_adapter, name: 'Windows OS', user: oliver) }

  before do
    ready(admin, oliver, project, adapter_for_linux, adapter_for_windows)
  end

  describe "GET index" do
    it_should_not_authorize(self, [:no_logged, :foreign]) do
      get :index
    end

    it "assigns users as @users" do
      sign_in admin
      get :index
      assigns(:adapters).should eq([adapter_for_linux, adapter_for_windows])
    end
  end

  describe "GET new" do
    it_should_not_authorize(self, [:no_logged, :foreign]) do
      get :new
    end

    [:html, :js].each do |format|
      it "assigns the requested adapter as @adapter for format #{format}" do
        sign_in admin
        get :new, format: format
        assigns(:adapter).class.should eq Tmt::AutomationAdapter
      end
    end
  end

  describe "GET edit" do
    it_should_not_authorize(self, [:no_logged, :foreign]) do
      get :edit, id: adapter_for_linux.id
    end

    [:html, :js].each do |format|
      it "assigns the requested adapter as @adapter for format #{format}" do
        sign_in admin
        get :edit, id: adapter_for_linux.id, format: format
        assigns(:adapter).should eq(adapter_for_linux)
      end
    end
  end

  describe "POST create" do
    describe "with valid params" do
      let(:valid_attributes) do
        Tmt::AutomationAdapter.new(
          user_id: oliver.id,
          project_id: project.id,
          name: 'Linux Mint',
          polling_interval: 5,
          adapter_type: Tmt.config[:oslc][:execution_adapter_type][:id]
        ).attributes
      end

      it_should_not_authorize(self, [:no_logged, :foreign]) do
        post :create, :automation_adapter => valid_attributes
      end

      [:html, :js].each do |format|
        it "creates a new Automation Adapter resource for format #{format}" do
          sign_in admin
          expect {
            post :create, :automation_adapter => valid_attributes, format: format
          }.to change(Tmt::AutomationAdapter, :count).by(1)
        end
      end

      it "redirects to the created Automation Adapter resource" do
        sign_in admin
        post :create, :automation_adapter => valid_attributes
        response.should redirect_to(admin_automation_adapters_path)
        response.status.should eq 302
      end

    end

    describe "with invalid params" do

      let(:invalid_attributes) {Tmt::AutomationAdapter.new.attributes}

      [:html, :js].each do |format|
        it "assigns a newly created but unsaved adapter as @adapter for format #{format}" do
          sign_in admin
          Tmt::AutomationAdapter.any_instance.stub(:save).and_return(false)
          post :create, automation_adapter: invalid_attributes, format: format
          assigns(:adapter).should be_a_new(Tmt::AutomationAdapter)
        end
      end

      it "re-renders the 'new' template" do
        sign_in admin
        Tmt::AutomationAdapter.any_instance.stub(:save).and_return(false)
        post :create, automation_adapter: invalid_attributes
        response.should render_template("new")
        response.status.should eq 200
      end
    end
  end

  describe "PUT update" do
    describe "with valid params" do
      let(:valid_attributes) do
        {name: 'New name'}
      end

      it_should_not_authorize(self, [:no_logged, :foreign]) do
        put :update, {:id => adapter_for_linux.id, :automation_adapter => valid_attributes}
      end

      it "updates the requested adapter" do
        sign_in admin
        adapter_for_linux.name.should_not eq("New name")
        put :update, {:id => adapter_for_linux.id, :automation_adapter => valid_attributes}
        adapter_for_linux.reload.name.should eq("New name")
      end

      it "assigns the requested adapter as @adapter" do
        sign_in admin
        put :update, {:id => adapter_for_linux.id, :automation_adapter => valid_attributes}
        assigns(:adapter).should eq(adapter_for_linux)
      end

      it "redirects to the machines" do
        sign_in admin
        put :update, {:id => adapter_for_linux.id, :automation_adapter => valid_attributes}
        response.should redirect_to(admin_automation_adapters_path)
        response.status.should eq 302
      end
    end

    describe "with invalid params" do
      let(:invalid_attributes) do
        {name: ''}
      end

      it "assigns the machine as @adapter" do
        sign_in admin
        Tmt::AutomationAdapter.any_instance.stub(:update).and_return(false)
        put :update, {:id => adapter_for_linux.id, :automation_adapter => invalid_attributes}
        assigns(:adapter).should eq adapter_for_linux
        response.status.should eq 200
      end

      it "re-renders the 'edit' template" do
        sign_in admin
        Tmt::AutomationAdapter.any_instance.stub(:update).and_return(false)
        put :update, {:id => adapter_for_linux.id, :automation_adapter => invalid_attributes}
        response.should render_template("edit")
      end
    end
  end
end
