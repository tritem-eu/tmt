require 'spec_helper'

describe Admin::EnumerationValuesController do
  extend CanCanHelper

  let(:valid_attributes) { { "enumeration_id" => enumeration.id, "text_value" => "'mech'", "numerical_value" => "1"   } }
  let(:admin) { create(:admin) }
  let(:user) { create(:user) }

  let(:enumeration) { create(:enumeration) }

  let(:enumeration_value) do
    create(:enumeration_value, enumeration: enumeration, numerical_value: "1", text_value: "frequency")
  end

  describe "GET 'new'" do
    [:html, :js].each do |format|
      it "assigns a new enumeration_value as @value for format: #{format}" do
        sign_in admin
        ready(enumeration)
        get :new, {:enumeration_id => enumeration.id, format: format}
        assigns(:value).should be_a_new(Tmt::EnumerationValue)
      end
    end

    it_should_not_authorize(self, [:no_logged, :foreign]) do
      ready(enumeration)
      get :new, {:enumeration_id => enumeration.id}
    end

  end

  describe "GET 'edit'" do

    [:html, :js].each do |format|
      it "assigns the requested enumeration_value as @value for format #{format}" do
        sign_in admin
        ready(enumeration_value)
        get :edit, {enumeration_id: enumeration.id, :id => enumeration_value.to_param, format: format}
        assigns(:value).should eq(enumeration_value)
      end
    end

    it_should_not_authorize(self, [:no_logged, :foreign]) do
      ready(enumeration_value)
      get :edit, {enumeration_id: enumeration.id, :id => enumeration_value.to_param}
    end

  end

  describe "DELETE 'destroy'" do

    it_should_not_authorize(self, [:no_logged, :foreign]) do
      ready(enumeration_value)
      get :destroy, {enumeration_id: enumeration.id, id: enumeration_value.to_param}
    end

    it "should destroy enumeration value" do
      sign_in admin
      enumeration = create(:enumeration, test_case_custom_field_id: nil, test_run_custom_field_id: nil)
      value = create(:enumeration_value, enumeration_id: enumeration.id)
      expect do
        get :destroy, {enumeration_id: enumeration.id, id: value.to_param}
      end.to change(Tmt::EnumerationValue, :count).by(-1)
      response.should redirect_to(admin_enumerations_url)
    end

    it "should not destroy enumeration value when enumeration is used by custom field" do
      sign_in admin
      enumeration = create(:enumeration, test_case_custom_field_id: create(:test_case_custom_field).id, test_run_custom_field_id: nil)
      value = create(:enumeration_value, enumeration_id: enumeration.id)
      expect do
        get :destroy, {enumeration_id: enumeration.id, id: value.to_param}
      end.to change(Tmt::EnumerationValue, :count).by(0)
      flash[:alert].should eq("You cannot destroy it when some custom field using it")
      response.should redirect_to(admin_enumerations_url)
    end

  end

  describe "POST create" do
    let(:valid_attributes) { { "enumeration_id" => enumeration.id, "text_value" => "'mech'", "numerical_value" => "1"   } }
    let(:enumeration) { create(:enumeration_unassigned) }

    describe "with valid params" do
      it_should_not_authorize(self, [:no_logged, :foreign]) do
        post :create, enumeration_id: enumeration.id, enumeration_value: valid_attributes
      end

      [:html, :js].each do |format|
        it "creates a new Campaign for format #{format}" do
          sign_in admin
          expect {
            post :create, enumeration_id: enumeration.id, enumeration_value: valid_attributes, format: format
          }.to change(Tmt::EnumerationValue, :count).by(1)
        end

        it "assigns a newly created enumeration value as @value for format #{format}" do
          sign_in admin
          post :create, enumeration_id: enumeration.id, enumeration_value: valid_attributes, format: format
          assigns(:value).should be_a(Tmt::EnumerationValue)
        end
      end

      it "redirects to the enumerations view" do
        sign_in admin
        post :create, enumeration_id: enumeration.id, enumeration_value: valid_attributes
        response.should redirect_to(admin_enumerations_path)
      end

    end

    describe "with invalid params" do
      [:html, :js].each do |format|
        it "assigns a newly created but unsaved campaign as @campaign for format #{format}" do
          sign_in admin
          post :create, enumeration_id: enumeration.id, enumeration_value: valid_attributes.merge({text_value: nil}), format: format
          assigns(:value).should be_a_new(Tmt::EnumerationValue)
        end
      end

      it "re-renders the 'new' template" do
        sign_in admin
        post :create, enumeration_id: enumeration.id, enumeration_value: valid_attributes.merge({text_value: nil})
        response.should render_template("new")
      end
    end
  end

  describe "PUT update" do
    let(:valid_attributes) { { "enumeration_id" => enumeration.id, "text_value" => "'mech'", "numerical_value" => "1"   } }
    let(:enumeration) { create(:enumeration_unassigned) }
    let(:enumeration_value) { create(:enumeration_value, enumeration_id: enumeration.id)}

    describe "with valid params" do
      it_should_not_authorize(self, [:no_logged, :foreign]) do
        put :update, enumeration_id: enumeration.id, id: enumeration_value.id, enumeration_value: {text_value: 'example'}
      end

      [:html, :js].each do |format|
        it "updates the requested campaign for format #{format}" do
          sign_in admin
          put :update, enumeration_id: enumeration.id, id: enumeration_value.id, enumeration_value: {text_value: 'example'}, format: format
          enumeration_value.reload.text_value.should eq('example')
        end

        it "assigns the requested enumeration value as @value for format #{format}" do
          sign_in admin
          put :update, enumeration_id: enumeration.id, id: enumeration_value.id, enumeration_value: {text_value: 'example'}, format: format
          assigns(:value).should be_a(Tmt::EnumerationValue)
        end
      end

      it "redirects to the enumerations view" do
        sign_in admin
        put :update, enumeration_id: enumeration.id, id: enumeration_value.id, enumeration_value: {text_value: 'example'}
        response.should redirect_to(admin_enumerations_path)
      end

      it "should show flash message" do
        sign_in admin
        put :update, enumeration_id: enumeration.id, id: enumeration_value.id, enumeration_value: {text_value: 'example'}
        flash[:notice].should eq("Enumeration Value was successfully updated")
      end
    end

    describe "with invalid params" do
      [:html, :js].each do |format|
        it "assigns the value as @value for format #{format}" do
          sign_in admin
          put :update, enumeration_id: enumeration.id, id: enumeration_value.id, enumeration_value: {numerical_value: nil}, format: format
          assigns(:value).should be_a(Tmt::EnumerationValue)
        end

        it "re-renders the 'edit' template for format #{format}" do
          sign_in admin
          put :update, enumeration_id: enumeration.id, id: enumeration_value.id, enumeration_value: {numerical_value: nil}, format: format
          response.should render_template("edit")
        end
      end
    end
  end

end
