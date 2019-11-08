require 'spec_helper'

describe Tmt::SetsController do
  extend CanCanHelper

  let(:valid_attributes) { { "name" => "MyString", project_id: project.id } }

  let(:project) { create(:project) }

  let(:campaign) { create(:campaign, project: project) }

  let(:set) { project.sets.create!(name: "Set 0")}

  let(:set1) { project.sets.create!(name: "Set 1")}

  let(:set_child) { project.sets.create!(name: "Child of Set", parent: set)}

  let(:user) do
    user = create(:user)
    project.add_member(user)
    user
  end

  let(:users) do
    {no_logged: nil, foreign_user: create(:user)}
  end

  describe "GET index" do

    it_should_not_authorize(self, [:no_logged, :foreign]) do
      ready(set)
      get :index, {project_id: project.id}
    end
=begin
    it "should render view" do
      ready(set, project)
      sign_in user
      rendered_view? do
        get :index, {project_id: project.id}
      end
    end
=end
    it "authorize user logged and is a member of project" do
      ready(set, project)
      sign_in user
      get :index, {project_id: project.id}
      response.should render_template('index')
    end

    it "render view where project has got opening campaign" do
      ready(set, project, campaign)
      sign_in user
      get :index, {project_id: project.id}
      response.should render_template('index')
    end


    it "assigns all a sets of project" do
      ready(set)
      sign_in user
      get :index, {project_id: project.id}
      assigns(:sets).should eq([set])
    end

    it "assigns test_cases of project which aren't deleted" do
      ready(set)
      test_cases = [
        create(:test_case, deleted_at: nil, project: project),
        create(:test_case, deleted_at: Time.now, project: project),
        create(:test_case, deleted_at: nil, project: project)
      ]

      sign_in user
      get :index, {project_id: project.id}
      assigns(:test_cases).should match_array([test_cases[0], test_cases[2]])
    end

    it "set should not have assigned test_case which is deleted on view" do
      ready(set)
      set.test_cases << create(:test_case, deleted_at: Time.now, project: project)
      sign_in user
      ::Tmt::Member.any_instance.stub(:updated_set_ids) { [set.id.to_s] }
      get :index, {project_id: project.id}
      assigns(:set_ids).should eq([set.id.to_s])
      assigns(:hash_tree)[:test_cases].should be_empty
    end
  end

  describe "GET new" do
=begin    
    it "should render view" do
      rendered_view? do
        sign_in user
        get :new, {project_id: project.id}
      end
    end
=end
    it "render template new when user is logged" do
      sign_in user
      get :new, {project_id: project.id}
      response.should render_template('new')
    end

    it_should_not_authorize(self, [:no_logged, :foreign]) do
      get :new, {project_id: project.id}
    end

    it "assigns a new set as @set" do
      sign_in user
      get :new, {project_id: project.id}
      assigns(:set).should be_a_new(Tmt::Set)
    end

    it "assigns a new project as @project" do
      sign_in user
      get :new, {project_id: project.id}
      assigns(:project).should eq(project)
    end

  end

  describe "GET edit" do
=begin
    it "should render view" do
      rendered_view? do
        sign_in user
        ready(set)
        get :edit, {project_id: project.id, :id => set.to_param}
      end
    end
=end
    it "assigns the requested set as @set" do
      sign_in user
      ready(set)
      get :edit, {project_id: project.id, :id => set.to_param}
      assigns(:set).should eq(set)
    end

    it_should_not_authorize(self, [:no_logged, :foreign]) do
      ready(set)
      get :edit, {project_id: project.id, :id => set.to_param}
    end

    it "assigns the requested sets as @sets" do
      sign_in user
      ready(set)
      another_set = create(:set, project: project)
      get :edit, {project_id: project.id, :id => set.to_param}
      assigns(:sets).should match_array([another_set])
    end

  end

  describe "POST create" do
    describe "with valid params" do
      it "creates a new Tmt::Set" do
        sign_in user
        expect {
          post :create, {project_id: project.id, :set => valid_attributes}
        }.to change(Tmt::Set, :count).by(1)
      end

      it_should_not_authorize(self, [:no_logged, :foreign]) do
        ready(set)
        post :create, {project_id: project.id, :set => valid_attributes}
      end

      it "assigns a newly created set as @set" do
        sign_in user
        post :create, {project_id: project.id, :set => valid_attributes}
        assigns(:set).should be_a(Tmt::Set)
        assigns(:set).should be_persisted
      end

      it "redirects to the index of sets" do
        sign_in user
        post :create, {project_id: project.id, :set => valid_attributes}
        response.should redirect_to(project_sets_path project)
      end

      it "send message for format html" do
        sign_in user
        post :create, {project_id: project.id, :set => valid_attributes}
        flash[:notice].should eq('Branch was successfully created')
      end

      it "send message for format js" do
        sign_in user
        post :create, {project_id: project.id, :set => valid_attributes, format: :js}
        flash[:notice].should eq('Branch was successfully created')
      end

    end

    describe "with invalid params" do
      it "assigns a newly created but unsaved set as @set" do
        sign_in user
        # Trigger the behavior that occurs when invalid params are submitted
        Tmt::Set.any_instance.stub(:save).and_return(false)
        post :create, {project_id: project.id, :set => { "name" => "invalid value" }}
        assigns(:set).should be_a_new(Tmt::Set)
      end

      it "assigns a sets as @sets" do
        sign_in user
        Tmt::Set.any_instance.stub(:save).and_return(false)
        post :create, {project_id: project.id, :set => { "name" => "invalid value" }}
        assigns(:sets).should eq(Tmt::Set.where(project_id: project.id))
      end

      it "re-renders the 'new' template" do
        sign_in user
        # Trigger the behavior that occurs when invalid params are submitted
        Tmt::Set.any_instance.stub(:save).and_return(false)
        post :create, {project_id: project.id, :set => { "name" => "invalid value" }}
        response.should render_template("new")
      end
    end
  end

  describe "PUT update" do
    describe "with valid params" do
      it "updates the requested tmt_set" do
        sign_in user
        ready(set)
        Tmt::Set.any_instance.should_receive(:update).with({ "name" => "MyString" })
        put :update, {project_id: project.id, :id => set.to_param, :set => { "name" => "MyString" }}
      end

      it_should_not_authorize(self, [:no_logged, :foreign]) do
        ready(set)
        put :update, {project_id: project.id, :id => set.to_param, :set => { "name" => "MyString" }}
      end

      it "assigns the requested tmt_set as @tmt_set" do
        sign_in user
        set = Tmt::Set.create! valid_attributes
        put :update, {project_id: project.id, :id => set.to_param, :set => valid_attributes}
        assigns(:set).should eq(set)
      end

      it "redirects to the tmt_set" do
        sign_in user
        set = Tmt::Set.create! valid_attributes
        put :update, {project_id: project.id, :id => set.to_param, :set => valid_attributes}
        response.should redirect_to(project_sets_path(project))
      end

      it "send message for format html" do
        sign_in user
        set = Tmt::Set.create! valid_attributes
        put :update, {project_id: project.id, :id => set.to_param, :set => valid_attributes}
        flash[:notice].should eq("Branch was successfully updated")
      end

      it "send message for format js" do
        sign_in user
        set = Tmt::Set.create! valid_attributes
        put :update, {project_id: project.id, :id => set.to_param, :set => valid_attributes, format: :js}
        flash[:notice].should eq("Branch was successfully updated")
      end
    end

    describe "with invalid params" do
      it "assigns the tmt_set as @tmt_set" do
        sign_in user
        set = Tmt::Set.create! valid_attributes
        # Trigger the behavior that occurs when invalid params are submitted
        Tmt::Set.any_instance.stub(:save).and_return(false)
        put :update, {project_id: project.id, :id => set.to_param, :set => { "name" => "invalid value" }}
        assigns(:set).should eq(set)
      end

      it "re-renders the 'edit' template" do
        sign_in user
        set = Tmt::Set.create! valid_attributes
        Tmt::Set.any_instance.stub(:save).and_return(false)
        put :update, {project_id: project.id, :id => set.to_param, :set => { "name" => "invalid value" }}
        response.should render_template("edit")
      end
    end
  end

  describe "DELETE destroy" do
    it "destroys the requested set" do
      sign_in user
      ready(set)
      expect {
        delete :destroy, {project_id: project.id, id: set.to_param}
      }.to change(Tmt::Set, :count).by(-1)
    end

    it_should_not_authorize(self, [:no_logged, :foreign]) do
      ready(set)
      delete :destroy, {project_id: project.id, id: set.to_param}
    end

    it "redirects to the sets list" do
      sign_in user
      set = Tmt::Set.create! valid_attributes
      delete :destroy, {project_id: project.id, id: set.to_param}
      response.should redirect_to(project_sets_url(project))
    end

    it "doesn't destroy the requested set when it has got children" do
      sign_in user
      ready(set)
      ready(set_child)
      expect {
        delete :destroy, {project_id: project.id, id: set.to_param}
      }.to change(Tmt::Set, :count).by(0)
    end
  end

  describe "GET download" do
    before do
      ready(set)
    end

    it_should_not_authorize(self, [:no_logged, :foreign]) do
      post :download, {project_id: project.id, id: set.id}
    end

    it "should generate zip file with last revisied version" do
      sign_in user
      test_case = create(:test_case, project: project)
      create(:test_case_version_with_revision, test_case: test_case)
      version = create(:test_case_version, test_case: test_case)
      set = create(:set, name: "set0", project: project)
      set.test_cases << test_case

      post :download, {project_id: project.id, id: set.id}
      FileUtils.mkdir_p('tmp/rspec')
      File.open('tmp/rspec/temporary.file', 'wb') do |file|
        file << response.body
      end
      Zip::InputStream.open('tmp/rspec/temporary.file') do |io|
        io.get_next_entry.name.should eq('set0/')
        entry = io.get_next_entry
        entry.name.should eq('set0/1-test_case_version')
        io.read.should eq(version.content)
        io.get_next_entry.should be_nil
      end
    end

    it "should generate zip file with empty content" do
      sign_in user
      test_case = create(:test_case, project: project)
      version = create(:test_case_version_with_revision, test_case: test_case)
      create(:test_case_version, test_case: test_case)

      set = create(:set, name: "set0", project: project)
      create(:set, name: "set1", project: project).test_cases << test_case

      post :download, {project_id: project.id, id: set.id}
      FileUtils.mkdir_p('tmp/rspec')
      File.open('tmp/rspec/temporary.file', 'wb') do |file|
        file << response.body
      end
      Zip::InputStream.open('tmp/rspec/temporary.file') do |io|
        io.get_next_entry.name.should eq('set0/')
        io.get_next_entry.should be_nil
      end
    end

    it "should generate zip file with nested set" do
      sign_in user
      test_case = create(:test_case, project: project)
      version = create(:test_case_version_with_revision, test_case: test_case)

      set_foreign = create(:set, name: "foreign", project: project)
      set_full = create(:set, name: "full", parent: set, project: project)
      set_full.test_cases << test_case
      set_empty = create(:set, name: "empty", parent: set, project: project)

      post :download, {project_id: project.id, id: set.id}
      FileUtils.mkdir_p('tmp/rspec')
      File.open('tmp/rspec/temporary.file', 'wb') do |file|
        file << response.body
      end
      Zip::InputStream.open('tmp/rspec/temporary.file') do |io|
        io.get_next_entry.name.should eq('Set 0/full/')
        io.get_next_entry.name.should eq('Set 0/full/1-script-git commit')
        io.get_next_entry.name.should eq('Set 0/empty/')
        io.get_next_entry.name.should eq('Set 0/')
        io.get_next_entry.should be_nil
      end
    end

  end

end
