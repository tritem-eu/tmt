require 'spec_helper'

[
  ["test_case", Tmt::TestCaseCustomField],
  ["test_run", Tmt::TestRunCustomField]
].each do |model_name, klass|
  describe Admin::CustomFieldsController do
    extend CanCanHelper

    def custom_fields_url(custom_field)
      if custom_field.kind_of?(Tmt::TestRunCustomField)
        admin_test_run_custom_fields_url
      elsif custom_field.kind_of?(Tmt::TestCaseCustomField)
        admin_test_case_custom_fields_url
      else
        nil
      end
    end

    def custom_field_url(custom_field)
      case custom_field.class.name.downcase
      when /run/
        admin_test_run_custom_field_url(custom_field)
      when /case/
        admin_test_case_custom_field_url(custom_field)
      else

      end
    end

    def get(arg, arg2={})
      arg2 = (arg2 || {}).merge({model_name: model_name})
      super(arg, arg2)
    end

    def post(arg, arg2={})
      arg2 = (arg2 || {}).merge({model_name: model_name})
      super(arg, arg2)
    end

    def put(arg, arg2={})
      arg2 = (arg2 || {}).merge({model_name: model_name})
      super(arg, arg2)
    end

    def delete(arg, arg2={})
      arg2 = (arg2 || {}).merge({model_name: model_name})
      super(arg, arg2)
    end

    let(:user) { create(:user) }

    let(:model_name) { model_name }

    let(:admin) do
      user = create(:user)
      user.add_role(:admin)
      user
    end

    let(:type_name) { :date }
    let(:valid_attributes) { { "name" => "MyString", type_name: type_name } }

    describe "GET index" do
      it_should_not_authorize(self, [:no_logged, :foreign, 'self.user']) do
        get :index
      end

      it "should has got access only admin" do
        sign_in admin
        get :index
        response.should render_template("index")
      end

      it "assigns all custom_fields as @custom_fields" do
        sign_in admin
        custom_field = klass.create! valid_attributes
        get :index
        assigns(:custom_fields).should match_array(klass.all)
      end
    end

    describe "GET show" do

      it_should_not_authorize(self, [:no_logged, :foreign], {klass: klass}) do |options|
        custom_field = options[:klass].create! valid_attributes
        get :show, {:id => custom_field.to_param}
      end

      it "render template index of custom field when user are logged like a admin" do
        sign_in admin
        custom_field = klass.create! valid_attributes
        get :show, {:id => custom_field.to_param}
        response.should render_template("show")
      end

      it "assigns the requested custom_field as @custom_field" do
        sign_in admin
        custom_field = klass.create! valid_attributes
        get :show, {:id => custom_field.to_param}
        assigns(:custom_field).should eq(custom_field)
      end
    end

    describe "GET new" do

      it_should_not_authorize(self, [:no_logged, :foreign], {klass: klass}) do |options|
        custom_field = klass.create! valid_attributes
        get :new
      end

      it "assigns a new custom_field as @custom_field" do
        sign_in admin
        get :new, {}
        response.should render_template("new")
      end

      it "assigns a new types as @types" do
        sign_in admin
        get :new, {}
        assigns(:type_names).should match_array(["text", "string", "bool", "int", "date", "enum"])
      end

      it "assigns all projests as @projects" do
        sign_in admin
        get :new
        assigns(:projects).should eq(Tmt::Project.all)
      end
    end

    describe "GET edit" do
      let(:custom_field) { klass.create! valid_attributes }

      it_should_not_authorize(self, [:no_logged, :foreign]) do
        get :edit, {:id => custom_field.to_param}
      end

      it "render template edit when user are logged like a admin" do
        sign_in admin
        get :edit, {:id => custom_field.to_param}
        response.should render_template('edit')
      end

      it "assigns the requested custom_field as custom_field" do
        sign_in admin
        get :edit, {:id => custom_field.to_param}
        assigns(:custom_field).should eq(custom_field)
      end

      it "assigns the requested types as types" do
        sign_in admin
        get :edit, {:id => custom_field.to_param}
        assigns(:type_names).should match_array(["text", "string", "bool", "int", "date", "enum"])
      end

      it "assigns the requested projects as projects" do
        sign_in admin
        get :edit, {:id => custom_field.to_param}
        assigns(:projects).should eq(Tmt::Project.all)
      end
    end

    describe "POST create" do
      describe "with valid params" do

        it_should_not_authorize(self, [:no_logged, :foreign, 'self.user']) do
          post :create, {:custom_field => valid_attributes}
        end

        it "render template show when user are logged like a admin" do
          sign_in admin
          post :create, {:custom_field => valid_attributes}
          response.should redirect_to(custom_field_url(klass.last))
        end

        it "creates a new klass" do
          sign_in admin
          expect {
            post :create, {:custom_field => valid_attributes}
          }.to change(klass, :count).by(1)
        end

        it "assigns a newly created custom_field as @custom_field" do
          sign_in admin
          post :create, {:custom_field => valid_attributes}
          assigns(:custom_field).should be_a(klass)
          assigns(:custom_field).should be_persisted
        end

        it "redirects to the created custom_field" do
          sign_in admin
          post :create, {:custom_field => valid_attributes}
          response.should redirect_to(custom_field_url(klass.last))
        end
      end

      describe "with invalid params" do
        it "assigns a newly created but unsaved custom_field as @custom_field" do
          sign_in admin
          # Trigger the behavior that occurs when invalid params are submitted
          klass.any_instance.stub(:save).and_return(false)
          post :create, {:custom_field => { "name" => "invalid value" }}
          assigns(:custom_field).should be_a_new(klass)
        end

        it "re-renders the 'new' template" do
          sign_in admin
          # Trigger the behavior that occurs when invalid params are submitted
          klass.any_instance.stub(:save).and_return(false)
          post :create, {:custom_field => { "name" => "invalid value" }}
          response.should render_template("new")
        end
      end
    end

    describe "PUT update" do
      describe "with valid params" do
        let(:custom_field) {klass.create! valid_attributes}

        it_should_not_authorize(self, [:no_logged, :foreign]) do
          put :update, {:id => custom_field.to_param, :custom_field => valid_attributes}
        end

        it "redirect to custom_field_url when user are logged like a admin" do
          sign_in admin
          put :update, {:id => custom_field.to_param, :custom_field => valid_attributes}
          response.should redirect_to(send("admin_#{model_name}_custom_field_url", custom_field))
        end

        it "updates the requested custom_field" do
          sign_in admin
          # Assuming there are no other custom_fields in the database, this
          # specifies that the TestCaseCustomField created on the previous line
          # receives the :update_attributes message with whatever params are
          # submitted in the request.
          klass.any_instance.should_receive(:update).with({ "name" => "MyString" })
          put :update, {:id => custom_field.to_param, :custom_field => { "name" => "MyString" }}
        end

        it "assigns the requested custom_field as @custom_field" do
          sign_in admin
          put :update, {:id => custom_field.to_param, :custom_field => valid_attributes}
          assigns(:custom_field).should eq(custom_field)
        end

        it "assigns the requested projects as @projects" do
          sign_in admin
          put :update, {:id => custom_field.to_param, :custom_field => valid_attributes}
          assigns(:projects).should eq(Tmt::Project.all)
        end

        it "assigns the requested types as @types" do
          sign_in admin
          put :update, {:id => custom_field.to_param, :custom_field => valid_attributes}
          assigns(:type_names).should match_array(["text", "string", "bool", "int", "date", "enum"])
        end

        it "redirects to the custom_field" do
          sign_in admin
          put :update, {:id => custom_field.to_param, :custom_field => valid_attributes}
          response.should redirect_to(custom_field_url(custom_field))
        end
      end

      describe "with invalid params" do
        it "assigns the custom_field as @custom_field" do
          sign_in admin
          custom_field = klass.create! valid_attributes
          # Trigger the behavior that occurs when invalid params are submitted
          klass.any_instance.stub(:save).and_return(false)
          put :update, {:id => custom_field.to_param, :custom_field => { "name" => "invalid value" }}
          assigns(:custom_field).should eq(custom_field)
        end

        it "re-renders the 'edit' template" do
          sign_in admin
          custom_field = klass.create! valid_attributes
          # Trigger the behavior that occurs when invalid params are submitted
          klass.any_instance.stub(:save).and_return(false)
          put :update, {:id => custom_field.to_param, :custom_field => { "name" => "invalid value" }}
          response.should render_template("edit")
        end
      end
    end

    describe "DELETE destroy" do
      let(:custom_field) { klass.create! valid_attributes }

      before do
        ready(custom_field)
      end

      it_should_not_authorize(self, [:no_logged, :foreign, 'self.user']) do
        delete :destroy, {id: custom_field.to_param}
      end

      it "destroys the requested custom_field" do
        sign_in admin
        expect {
          delete :destroy, {id: custom_field.to_param}
        }.to change(klass, :count).by(0)
        custom_field.reload.deleted_at.class.should eq ActiveSupport::TimeWithZone
      end

      it "redirects to the custom_fields list" do
        sign_in admin
        delete :destroy, {id: custom_field.to_param}
        response.should redirect_to(custom_fields_url(custom_field))
      end
    end

    describe "GET clone" do
      let(:custom_field) { create("#{model_name}_custom_field".to_sym, name: 'exampleName', project: create(:project)) }

      it_should_not_authorize(self, [:no_logged, :foreign, 'self.user']) do
        post :clone, {id: custom_field.id}
      end

      it "assigns projects as @custom_field" do
        sign_in admin
        post :clone, {id: custom_field.id}
        assigns(:projects).should eq(Tmt::Project.all)
      end

      it "assigns type names as @type_names" do
        sign_in admin
        post :clone, {id: custom_field.id}
        assigns(:type_names).should_not be_empty
      end

      it "assigns not used enumerations as @enumerations" do
        sign_in admin
        enumeration_for_test_case = create(:enumeration, test_run_custom_field_id: nil, test_case_custom_field_id: create(:test_case).id)
        enumeration_for_test_run = create(:enumeration, test_run_custom_field_id: create(:test_run).id, test_case_custom_field_id: nil)
        enumeration_not_used = create(:enumeration, test_run_custom_field_id: nil, test_case_custom_field_id: nil)
        post :clone, {id: custom_field.id}
        assigns(:enumerations).should include(enumeration_not_used)
        assigns(:enumerations).should_not include(enumeration_for_test_case)
        assigns(:enumerations).should_not include(enumeration_for_test_run)
      end

      describe "for type string" do

        let(:custom_field) { create("#{model_name}_custom_field_for_string".to_sym, name: 'exampleName', project: create(:project)) }

        it "render template clone when user is logged like a admin" do
          sign_in admin
          post :clone, {id: custom_field.id}
          response.should render_template(:clone)
        end

        it "assigns custom_field as @custom_field" do
          sign_in admin
          post :clone, {id: custom_field.id}
          assigns(:custom_field).should be_a(klass)
          assigns(:custom_field).id.should be_nil
          assigns(:custom_field).type_name.should eq('string')
          assigns(:custom_field).name.should eq('exampleName')
          assigns(:custom_field).project_id.should be_nil
        end

      end

      describe "for type text" do

        let(:custom_field) { create("#{model_name}_custom_field_for_text".to_sym, name: 'exampleName', project: create(:project)) }

        it "render template clone when user is logged like a admin" do
          sign_in admin
          post :clone, {id: custom_field.id}
          response.should render_template(:clone)
        end

        it "assigns custom_field as @custom_field" do
          sign_in admin
          post :clone, {id: custom_field.id}
          assigns(:custom_field).should be_a(klass)
          assigns(:custom_field).id.should be_nil
          assigns(:custom_field).type_name.should eq('text')
          assigns(:custom_field).name.should eq('exampleName')
          assigns(:custom_field).project_id.should be_nil
        end

      end

      describe "for type date" do

        let(:custom_field) { create("#{model_name}_custom_field_for_date".to_sym, name: 'exampleName', project: create(:project)) }

        it "render template clone when user is logged like a admin" do
          sign_in admin
          post :clone, {id: custom_field.id}
          response.should render_template(:clone)
        end

        it "assigns custom_field as @custom_field" do
          sign_in admin
          post :clone, {id: custom_field.id}
          assigns(:custom_field).should be_a(klass)
          assigns(:custom_field).id.should be_nil
          assigns(:custom_field).type_name.should eq('date')
          assigns(:custom_field).name.should eq('exampleName')
          assigns(:custom_field).project_id.should be_nil
        end

      end

      describe "for type intiger" do

        let(:custom_field) { create("#{model_name}_custom_field_for_integer".to_sym, name: 'exampleName', project: create(:project)) }

        it "render template clone when user is logged like a admin" do
          sign_in admin
          post :clone, {id: custom_field.id}
          response.should render_template(:clone)
        end

        it "assigns custom_field as @custom_field" do
          sign_in admin
          post :clone, {id: custom_field.id}
          assigns(:custom_field).should be_a(klass)
          assigns(:custom_field).id.should be_nil
          assigns(:custom_field).type_name.should eq('int')
          assigns(:custom_field).name.should eq('exampleName')
          assigns(:custom_field).project_id.should be_nil
        end

      end

      describe "for type bool" do

        let(:custom_field) { create("#{model_name}_custom_field_for_bool".to_sym, name: 'boolName', project: create(:project)) }

        it "render template clone when user is logged like a admin" do
          sign_in admin
          post :clone, {id: custom_field.id}
          response.should render_template(:clone)
        end

        it "assigns custom_field as @custom_field" do
          sign_in admin
          post :clone, {id: custom_field.id}
          assigns(:custom_field).should be_a(klass)
          assigns(:custom_field).id.should be_nil
          assigns(:custom_field).type_name.should eq('bool')
          assigns(:custom_field).name.should eq('boolName')
          assigns(:custom_field).project_id.should be_nil
        end

      end

      describe "for type enumeration" do

        let(:custom_field) { create("#{model_name}_custom_field_for_enumeration".to_sym, name: 'enumerationName', project: create(:project)) }

        it "render template clone when user is logged like a admin" do
          sign_in admin
          post :clone, {id: custom_field.id}
          response.should render_template(:clone)
        end

        it "assigns custom_field as @custom_field" do
          sign_in admin
          post :clone, {id: custom_field.id}
          assigns(:custom_field).should be_a(klass)
          assigns(:custom_field).id.should be_nil
          assigns(:custom_field).type_name.should eq('enum')
          assigns(:custom_field).name.should eq('enumerationName')
          assigns(:custom_field).project_id.should be_nil
        end

        it "should clone enumeration" do
          sign_in admin
          ready(custom_field)
          enumeration = custom_field.enumeration
          post :clone, {id: custom_field.id}
          assigns(:custom_field).enumeration.should_not be_nil
          assigns(:custom_field).enumeration.should_not eq(enumeration)
          assigns(:custom_field).enumeration.name.should eq(enumeration.name)
        end

        it "should not clone enumeration when exist one doesn't used" do
          sign_in admin
          ready(custom_field)
          enumeration = custom_field.enumeration
          expect do
            post :clone, {id: custom_field.id}
          end.to change(Tmt::Enumeration, :count).by(1)
          expect do
            post :clone, {id: custom_field.id}
          end.to change(Tmt::Enumeration, :count).by(0)
        end

        it "should clone values of enumeration" do
          sign_in admin
          old_values = custom_field.enumeration.values
          post :clone, {id: custom_field.id}
          new_values = assigns(:custom_field).enumeration.values

          new_values.pluck(:text_value).should match_array(['mirror', 'medium', 'high'])
          new_values.pluck(:id).should_not include(old_values.first.id)
        end

      end
    end
  end
end
