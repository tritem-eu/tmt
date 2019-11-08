require 'spec_helper'

describe Admin::TestCaseTypesController do
  extend CanCanHelper
  let(:valid_attributes) { { name: "MyString 01.2014"} }
  let(:test_case_type) { Tmt::TestCaseType.create! valid_attributes }

  let(:admin) { create(:admin) }
  let(:user) { create(:user) }

  describe "GET index" do

    it "assigns all test_case_types as @test_case_types" do
      sign_in admin
      Tmt::TestCaseType.delete_all
      type_deleted = create(:test_case_type, deleted_at: Time.now)
      type_undeleted = create(:test_case_type, deleted_at: nil)
      get :index, {}
      assigns(:test_case_types).should match_array([type_undeleted])
    end

    it_should_not_authorize(self, [:no_logged, :foreign]) do
      test_case_type = Tmt::TestCaseType.create! valid_attributes
      get :index, {}
    end

  end

  describe "GET new" do
    it "assigns a new test_case_type as @test_case_type" do
      sign_in admin
      get :new, {}
      assigns(:test_case_type).should be_a_new(Tmt::TestCaseType)
    end

    it_should_not_authorize(self, [:no_logged, :foreign]) do
      get :new, {}
    end
  end

  describe "GET edit" do
    it "assigns the requested test_case_type as @test_case_type" do
      sign_in admin
      test_case_type = Tmt::TestCaseType.create! valid_attributes
      get :edit, {:id => test_case_type.to_param}
      assigns(:test_case_type).should eq(test_case_type)
    end

    it_should_not_authorize(self, [:no_logged, :foreign]) do
      test_case_type = Tmt::TestCaseType.create! valid_attributes
      get :edit, {:id => test_case_type.to_param}
    end

  end

  describe "GET show" do

    before do
      ready test_case_type
    end

    it "assigns the requested test_case_type as @test_case_type" do
      sign_in user
      get :show, {:id => test_case_type.to_param}
      assigns(:test_case_type).should eq(test_case_type)
    end

    it_should_not_authorize(self, [:no_logged]) do
      test_case_type = Tmt::TestCaseType.create! valid_attributes.merge({name: 'type name 02.2014'})
      get :show, {:id => test_case_type.to_param}
    end

  end

  describe "POST create" do
    describe "with valid params" do
      it "creates a new TestCaseType" do
        sign_in admin
        expect {
          post :create, {:test_case_type => valid_attributes}
        }.to change(Tmt::TestCaseType, :count).by(1)
      end

      it_should_not_authorize(self, [:no_logged, :foreign]) do
        post :create, {:test_case_type => valid_attributes}
      end

      it "assigns a newly created test_case_type as @test_case_type" do
        sign_in admin
        post :create, {:test_case_type => valid_attributes}
        assigns(:test_case_type).should be_a(Tmt::TestCaseType)
        assigns(:test_case_type).should be_persisted
      end

      it "redirects to the created test_case_type" do
        sign_in admin
        post :create, {:test_case_type => valid_attributes}
        response.should redirect_to(admin_test_case_types_path)
      end
    end

    describe "with invalid params" do
      it "assigns a newly created but unsaved test_case_type as @test_case_type" do
        sign_in admin
        # Trigger the behavior that occurs when invalid params are submitted
        Tmt::TestCaseType.any_instance.stub(:save).and_return(false)
        post :create, {:test_case_type => { "name" => "invalid value 07.2013" }}
        assigns(:test_case_type).should be_a_new(Tmt::TestCaseType)
      end

      it "re-renders the 'new' template" do
        sign_in admin
        # Trigger the behavior that occurs when invalid params are submitted
        Tmt::TestCaseType.any_instance.stub(:save).and_return(false)
        post :create, {:test_case_type => { "name" => "invalid value 06.2013" }}
        response.should render_template("new")
      end
    end
  end

  describe "PUT update" do
    describe "with valid params" do
      it "updates the requested test_case_type" do
        sign_in admin
        test_case_type = Tmt::TestCaseType.create! valid_attributes
        # Assuming there are no other test_case_types in the database, this
        # specifies that the Tmt::TestCaseType created on the previous line
        # receives the :update_attributes message with whatever params are
        # submitted in the request.
        Tmt::TestCaseType.any_instance.should_receive(:update).with({ "name" => "MyString 08.2014" })
        put :update, {:id => test_case_type.to_param, :test_case_type => { "name" => "MyString 08.2014" }}
      end

      it_should_not_authorize(self, [:no_logged, :foreign]) do
        test_case_type = Tmt::TestCaseType.create! valid_attributes
        put :update, {:id => test_case_type.to_param, :test_case_type => { "name" => "MyString 10.2014" }}
      end

      it "assigns the requested test_case_type as @test_case_type" do
        sign_in admin
        test_case_type = Tmt::TestCaseType.create! valid_attributes
        put :update, {:id => test_case_type.to_param, :test_case_type => valid_attributes}
        assigns(:test_case_type).should eq(test_case_type)
      end

      it "redirects to the test_case_type" do
        sign_in admin
        test_case_type = Tmt::TestCaseType.create! valid_attributes
        put :update, {:id => test_case_type.to_param, :test_case_type => valid_attributes}
        response.should redirect_to(admin_test_case_types_path)
      end
    end

    describe "with invalid params" do
      it "assigns the test_case_type as @test_case_type" do
        sign_in admin
        test_case_type = Tmt::TestCaseType.create! valid_attributes
        # Trigger the behavior that occurs when invalid params are submitted
        Tmt::TestCaseType.any_instance.stub(:save).and_return(false)
        put :update, {:id => test_case_type.to_param, :test_case_type => { "name" => "invalid value 11.2014" }}
        assigns(:test_case_type).should eq(test_case_type)
      end

      it "re-renders the 'edit' template" do
        sign_in admin
        test_case_type = Tmt::TestCaseType.create! valid_attributes
        # Trigger the behavior that occurs when invalid params are submitted
        Tmt::TestCaseType.any_instance.stub(:save).and_return(false)
        put :update, {:id => test_case_type.to_param, :test_case_type => { "name" => "invalid value 12.2014" }}
        response.should render_template("edit")
      end
    end
  end

  describe "DELETE destroy" do
    it "destroys the requested test_case_type" do
      sign_in admin
      test_case_type = Tmt::TestCaseType.create! valid_attributes
      test_case_type.reload.deleted_at.should be_nil
      expect {
        delete :destroy, {:id => test_case_type.to_param}
      }.to change(Tmt::TestCaseType, :count).by(0)
      test_case_type.reload.deleted_at.should_not be_nil
    end

    it_should_not_authorize(self, [:no_logged, :foreign]) do
      test_case_type = Tmt::TestCaseType.create! valid_attributes
      delete :destroy, {:id => test_case_type.to_param}
    end

    it "redirects to the test_case_types list" do
      sign_in admin
      test_case_type = Tmt::TestCaseType.create! valid_attributes
      delete :destroy, {:id => test_case_type.to_param}
      response.should redirect_to(admin_test_case_types_url)
    end
  end

end
