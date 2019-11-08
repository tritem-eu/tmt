require 'spec_helper'
describe Admin::EnumerationsController do
  extend CanCanHelper

  let(:admin) { create(:admin) }

  let(:valid_attributes) { { name: "Examle", "test_case_custom_field_id" => "1" } }

  describe "GET index" do
    it_should_not_authorize(self, [:no_logged]) do
      enumeration = Tmt::Enumeration.create! valid_attributes
      get :index, {}
    end

    it "assigns all enumerations as @enumerations" do
      sign_in admin
      enumeration = Tmt::Enumeration.create! valid_attributes
      get :index, {}
      assigns(:enumerations).should eq([enumeration])
    end
  end

  describe "GET new" do

    it_should_not_authorize(self, [:no_logged, :foreign]) do
      get :new
    end

    [:js, :html].each do |format|
      describe "for format #{format}" do
        it "assigns a new enumeration as @enumeration" do
          sign_in admin
          get :new, {format: format}
          assigns(:enumeration).should be_a_new(Tmt::Enumeration)
        end
      end
    end
  end

  describe "GET edit" do
    it_should_not_authorize(self, [:no_logged, :foreign]) do
      enumeration = Tmt::Enumeration.create! valid_attributes
      get :edit, {:id => enumeration.to_param}
    end

    [:js, :html].each do |format|
      describe "for format #{format}" do
        it "assigns the requested enumeration as @enumeration" do
          sign_in admin
          enumeration = Tmt::Enumeration.create! valid_attributes
          get :edit, {id: enumeration.to_param, format: format}
          assigns(:enumeration).should eq(enumeration)
        end
      end
    end
  end

  describe "POST create" do
    describe "with valid params" do
      it_should_not_authorize(self, [:no_logged, :foreign]) do
        post :create, {:enumeration => valid_attributes}
      end

      it "creates a new Enumeration" do
        sign_in admin
        expect {
          post :create, {:enumeration => valid_attributes}
        }.to change(Tmt::Enumeration, :count).by(1)
      end

      it "assigns a newly created enumeration as @enumeration" do
        sign_in admin
        post :create, {:enumeration => valid_attributes}
        assigns(:enumeration).should be_a(Tmt::Enumeration)
        assigns(:enumeration).should be_persisted
      end

      it "redirects to the list of enumerations" do
        sign_in admin
        post :create, {:enumeration => valid_attributes}
        response.should redirect_to(admin_enumerations_url)
      end
    end

    describe "with invalid params" do
      it "assigns a newly created but unsaved enumeration as @enumeration" do
        sign_in admin
        # Trigger the behavior that occurs when invalid params are submitted
        Tmt::Enumeration.any_instance.stub(:save).and_return(false)
        post :create, {:enumeration => { "test_case_custom_field_id" => "invalid value" }}
        assigns(:enumeration).should be_a_new(Tmt::Enumeration)
      end

      it "re-renders the 'new' template" do
        sign_in admin
        # Trigger the behavior that occurs when invalid params are submitted
        Tmt::Enumeration.any_instance.stub(:save).and_return(false)
        post :create, {:enumeration => { "test_case_custom_field_id" => "invalid value" }}
        response.should render_template("new")
      end
    end
  end

  describe "PUT update" do
    describe "with valid params" do
      it_should_not_authorize(self, [:no_logged, :foreign]) do
        enumeration = Tmt::Enumeration.create! valid_attributes
        put :update, {:id => enumeration.to_param, :enumeration => { "test_case_custom_field_id" => "1" }}
      end

      it "updates the requested enumeration" do
        sign_in admin
        enumeration = Tmt::Enumeration.create! valid_attributes
        Tmt::Enumeration.any_instance.should_receive(:update).with({ "test_case_custom_field_id" => "1" })
        put :update, {:id => enumeration.to_param, enumeration: { "test_case_custom_field_id" => "1" }}
      end

      it "assigns the requested enumeration as @enumeration" do
        sign_in admin
        enumeration = Tmt::Enumeration.create! valid_attributes
        put :update, {:id => enumeration.to_param, :enumeration => valid_attributes}
        assigns(:enumeration).should eq(enumeration)
      end

      it "redirects to the enumeration" do
        sign_in admin
        enumeration = Tmt::Enumeration.create! valid_attributes
        put :update, {:id => enumeration.to_param, :enumeration => valid_attributes}
        response.should redirect_to(admin_enumerations_path)
      end
    end

    describe "with invalid params" do
      it "assigns the enumeration as @enumeration" do
        sign_in admin
        enumeration = Tmt::Enumeration.create! valid_attributes
        # Trigger the behavior that occurs when invalid params are submitted
        Tmt::Enumeration.any_instance.stub(:save).and_return(false)
        put :update, {:id => enumeration.to_param, :enumeration => { "test_case_custom_field_id" => "invalid value" }}
        assigns(:enumeration).should eq(enumeration)
      end

      it "re-renders the 'edit' template" do
        sign_in admin
        enumeration = Tmt::Enumeration.create! valid_attributes
        # Trigger the behavior that occurs when invalid params are submitted
        Tmt::Enumeration.any_instance.stub(:save).and_return(false)
        put :update, {:id => enumeration.to_param, :enumeration => { "_test_case_custom_field_id" => "invalid value" }}
        response.should render_template("edit")
      end
    end
  end

  describe "DELETE destroy" do
    it "destroys the requested enumeration" do
      sign_in admin
      enumeration = Tmt::Enumeration.create! valid_attributes
      expect {
        delete :destroy, {:id => enumeration.to_param}
      }.to change(Tmt::Enumeration, :count).by(-1)
    end

    it "redirects to the enumerations list" do
      sign_in admin
      enumeration = Tmt::Enumeration.create! valid_attributes
      delete :destroy, {:id => enumeration.to_param}
      response.should redirect_to(admin_enumerations_url)
    end
  end

end
