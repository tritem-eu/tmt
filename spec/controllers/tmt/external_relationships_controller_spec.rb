require 'spec_helper'

describe Tmt::ExternalRelationshipsController do
  extend CanCanHelper

  let(:valid_attributes) { { url: server_url, value: "MyString", rq_id: test_case.id, kind: 'url' } }

  let(:external_relationship) { create(:external_relationship, source: test_case) }
  let(:project) { create(:project) }
  let(:test_case) { create(:test_case, project: project) }

  let(:user) do
    user = create(:user)
    project.add_member(user)
    user
  end

  before do
    ready(test_case)
  end

  describe "GET show" do
=begin
    it "should render view" do
      sign_in user
      ready(external_relationship)
      rendered_view? do
        get :show, {source_type: test_case.class.name, source_id: test_case.id, :id => external_relationship.to_param}
      end
    end
=end
    it "assigns the requested external_relationship as @external_relationship" do
      sign_in user
      ready(external_relationship)
      get :show, {source_type: test_case.class.name, source_id: test_case.id, :id => external_relationship.to_param}
      assigns(:external_relationship).should eq(external_relationship)
    end

    it_should_not_authorize(self, [:no_logged, :foreign]) do
      ready(external_relationship)
      get :show, {source_type: test_case.class.name, source_id: test_case.id, :id => external_relationship.to_param}
    end
  end

  describe "GET new" do

    [:html, :js].each do |format|
      it "assigns a new external_relationship for format #{format}" do
        sign_in user
        get :new, {source_type: test_case.class.name, source_id: test_case.id, format: format}
        assigns(:external_relationship).should be_a_new(Tmt::ExternalRelationship)
      end
    end

    it_should_not_authorize(self, [:no_logged, :foreign]) do
      get :new, {source_type: test_case.class.name, source_id: test_case.id}
    end

  end

  describe "GET edit" do
    [:html, :js].each do |format|
      it "assigns the requested external_relationship for format #{format}" do
        sign_in user
        ready(external_relationship, test_case)
        get :edit, {source_type: test_case.class.name, source_id: test_case.id, :id => external_relationship.to_param, format: format}
        assigns(:external_relationship).should eq(external_relationship)
      end
    end

    it_should_not_authorize(self, [:no_logged, :foreign]) do
      ready(external_relationship)
      get :edit, {source_type: test_case.class.name, source_id: test_case.id, :id => external_relationship.to_param}
    end
  end

  describe "POST create" do
    before do
      ready(test_case)
    end

    describe "with valid params" do
      [:html, :js].each do |format|
        it "creates a new external_relationship for format #{format}" do
          sign_in user
          expect {
            post :create, {source_type: test_case.class.name, source_id: test_case.id, :external_relationship => valid_attributes, format: format}
          }.to change(Tmt::ExternalRelationship, :count).by(1)
        end

        it "creates a new external_relationship when kind is 'url' for format #{format}" do
          sign_in user
          Tmt::ExternalRelationship.delete_all
          expect {
            valid_attributes['kind'] = 'url'
            post :create, {source_type: test_case.class.name, source_id: test_case.id, :external_relationship => valid_attributes, format: format}
          }.to change(Tmt::ExternalRelationship, :count).by(1)
          entry = Tmt::ExternalRelationship.first
          entry.rq_id.should be_nil
          entry.url.should eq valid_attributes[:url]
          entry.value.should eq valid_attributes[:value]
        end

        it "creates a new external_relationship when kind is 'rq_id' for format #{format}" do
          sign_in user
          Tmt::ExternalRelationship.delete_all
          expect {
            valid_attributes['kind'] = 'rq_id'
            post :create, {source_type: test_case.class.name, source_id: test_case.id, :external_relationship => valid_attributes, format: format}
          }.to change(Tmt::ExternalRelationship, :count).by(1)
          entry = Tmt::ExternalRelationship.first
          entry.rq_id.should eq valid_attributes[:rq_id]
          entry.url.should be_nil
          entry.value.should be_nil
        end

      end

      it_should_not_authorize(self, [:no_logged, :foreign]) do
        post :create, {source_type: test_case.class.name, source_id: test_case.id, :external_relationship => valid_attributes}
      end

      it "assigns a newly created external_relationship as @external_relationship" do
        sign_in user
        post :create, {source_type: test_case.class.name, source_id: test_case.id, :external_relationship => valid_attributes}
        assigns(:external_relationship).should be_a(Tmt::ExternalRelationship)
        assigns(:external_relationship).should be_persisted
      end

      it "redirects to the created external_relationship" do
        sign_in user
        post :create, {source_type: test_case.class.name, source_id: test_case.id, external_relationship: valid_attributes}
        response.should redirect_to([project, test_case])
      end

      it "should not authorize when test case is locked by other user" do
        test_case.update(steward_id: 0)
        sign_in user
        amount = Tmt::ExternalRelationship.count
        post :create, {source_type: test_case.class.name, source_id: test_case.id, external_relationship: valid_attributes}
        Tmt::ExternalRelationship.count.should eq(amount)
      end

      it "should authorize when test case is locked by the same user who is loged in" do
        test_case.update(steward_id: user.id)
        sign_in user
        amount = Tmt::ExternalRelationship.count
        post :create, {source_type: test_case.class.name, source_id: test_case.id, external_relationship: valid_attributes}
        Tmt::ExternalRelationship.count.should eq(amount + 1)
      end

    end

    describe "with invalid params" do
      it "assigns a newly created but unsaved external_relationship as @external_relationship" do
        sign_in user
        Tmt::ExternalRelationship.any_instance.stub(:save).and_return(false)
        post :create, {source_type: test_case.class.name, source_id: test_case.id, :external_relationship => { "value" => "invalid value" }}
        assigns(:external_relationship).should be_a_new(Tmt::ExternalRelationship)
      end

      [:html, :js].each do |format|
        it "re-renders the 'new' template for format #{format}" do
          sign_in user
          Tmt::ExternalRelationship.any_instance.stub(:save).and_return(false)
          post :create, {source_type: test_case.class.name, source_id: test_case.id, :external_relationship => { "value" => "invalid value" }, format: format}
          response.should render_template('new')
        end
      end
    end
  end

  describe "PUT update" do
    describe "with valid params" do
=begin
      it "should render view" do
        sign_in user
        ready(external_relationship)
        Tmt::ExternalRelationship.any_instance.should_receive(:update).with({ "value" => "MyString" })
        rendered_view? do
          put :update, {source_type: test_case.class.name, source_id: test_case.id, :id => external_relationship.to_param, :external_relationship => { "value" => "MyString" }}
        end
      end
=end
      it "updates the requested external_relationship" do
        sign_in user
        ready(external_relationship)
        Tmt::ExternalRelationship.any_instance.should_receive(:update).with({ "value" => "MyString" })
        put :update, {source_type: test_case.class.name, source_id: test_case.id, :id => external_relationship.to_param, :external_relationship => { "value" => "MyString" }}
      end

      it_should_not_authorize(self, [:no_logged, :foreign]) do
        ready(test_case, external_relationship)
        put :update, {source_type: test_case.class.name, source_id: test_case.id, :id => external_relationship.to_param, :external_relationship => { "value" => "MyString" }}
      end

      it "assigns the requested external_relationship as @external_relationship" do
        sign_in user
        ready(external_relationship)
        put :update, {source_type: test_case.class.name, source_id: test_case.id, :id => external_relationship.to_param, :external_relationship => valid_attributes}
        assigns(:external_relationship).should eq(external_relationship)
      end

      it "redirects to the external_relationship" do
        sign_in user
        ready(project, test_case, external_relationship)
        put :update, {source_type: test_case.class.name, source_id: test_case.id, :id => external_relationship.to_param, :external_relationship => valid_attributes}
        response.should redirect_to([project, test_case])
      end

      describe 'test case instance is locked' do
        it "should not authorize when test case is locked by other user" do
          test_case.update(steward_id: 0)
          sign_in user
          external_relationship.url.should eq 'http://www.example.com'
          updated_at = external_relationship.updated_at
          put :update, {source_type: test_case.class.name, source_id: test_case.id, :id => external_relationship.to_param, :external_relationship => {url: 'http://www.example.com.pl'}}
          external_relationship.url.should_not eq 'http://www.example.com.pl'
          external_relationship.reload.updated_at.in_time_zone.to_s.should eq(updated_at.in_time_zone.to_s)
        end

        it "should authorize when test case is locked by the same user who is loged in" do
          test_case.update(steward_id: user.id)
          sign_in user
          external_relationship.url.should eq 'http://www.example.com'
          put :update, {source_type: test_case.class.name, source_id: test_case.id, :id => external_relationship.to_param, :external_relationship => {url: 'http://www.example.com.pl'}}
          external_relationship.reload.url.should eq 'http://www.example.com.pl'
        end
      end
    end

    describe "with invalid params" do
      it "assigns the external_relationship as @external_relationship" do
        sign_in user
        ready(external_relationship)
        Tmt::ExternalRelationship.any_instance.stub(:save).and_return(false)
        put :update, {source_type: test_case.class.name, source_id: test_case.id, :id => external_relationship.to_param, :external_relationship => { "value" => "invalid value" }}
        assigns(:external_relationship).should eq(external_relationship)
      end

      it "re-renders the 'edit' template" do
        sign_in user
        ready(external_relationship)
        # Trigger the behavior that occurs when invalid params are submitted
        Tmt::ExternalRelationship.any_instance.stub(:save).and_return(false)
        put :update, {source_type: test_case.class.name, source_id: test_case.id, :id => external_relationship.to_param, :external_relationship => { "value" => "invalid value" }}
        response.should render_template("edit")
      end
    end
  end

  describe "DELETE destroy" do
    [:html, :js].each do |format|
      it "destroys the requested external_relationship for format #{format}" do
        sign_in user
        ready(external_relationship)
        expect {
          delete :destroy, {source_type: test_case.class.name, source_id: test_case.id, :id => external_relationship.to_param, format: format}
        }.to change(Tmt::ExternalRelationship, :count).by(-1)
      end
    end

    it "redirects to the external_relationships list" do
      sign_in user
      ready(external_relationship)
      source = external_relationship.source

      delete :destroy, {source_type: test_case.class.name, source_id: test_case.id, :id => external_relationship.to_param}
      response.should redirect_to([project, source])
    end

    it_should_not_authorize(self, [:no_logged, :foreign]) do
      ready(external_relationship)
      delete :destroy, {source_type: test_case.class.name, source_id: test_case.id, :id => external_relationship.to_param}
    end
  end

end
