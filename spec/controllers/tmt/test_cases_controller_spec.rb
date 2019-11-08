require 'spec_helper'

describe Tmt::TestCasesController do
  extend CanCanHelper

  let(:project) { create(:project) }
  let(:type) {create(:test_case_type, name: "html")}
  let(:type_file) {create(:test_case_type, name: "sequence", has_file: true)}

  let(:test_case) { Tmt::TestCase.create!(valid_attributes) }

  let(:user) { create(:user)}

  let(:user_of_project) do
    user = create(:user)
    project.add_member(user)
    user
  end

  let(:admin) do
    user = create(:user)
    user.add_role(:admin)
    user
  end

  let(:valid_attributes) do
    {
      "name" => "MyString",
      project_id: project.id,
      creator_id: user.id,
      type_id: type.id
    }
  end

  describe "GET index" do
    before do
      ready( project)
    end

    it_should_not_authorize(self, [:no_logged, :foreign]) do
      get :index, {project_id: project.id}
    end
=begin
    it "should render view" do
      sign_in user_of_project
      rendered_view? do
        sign_in user_of_project
        get :index, {project_id: project.id}
      end
    end
=end
    it "authorize user logged and is a member of project" do
      sign_in user_of_project
      get :index, {project_id: project.id}
      response.should render_template('index')
    end

    it "assigns test_cases with current projet" do
      test_cases = [
        create(:test_case, project: project),
        create(:test_case, project: project),
        create(:test_case)
      ]
      sign_in user_of_project
      get :index, {project_id: project.id}
      assigns(:test_cases).should match_array([test_cases[0], test_cases[1]])
    end

    it "assigns test_cases of project which aren't deleted" do
      test_cases = [
        create(:test_case, deleted_at: nil, project: project),
        create(:test_case, deleted_at: Time.now, project: project),
        create(:test_case, deleted_at: nil, project: project)
      ]
      sign_in user_of_project
      get :index, {project_id: project.id}
      assigns(:test_cases).should match_array([test_cases[0], test_cases[2]])
    end
  end

  describe "GET show" do

    let(:member) { Tmt::Member.where(project: project, user: user_of_project).first }

    it "assigns the requested test_case as @test_case" do
      sign_in user_of_project
      get :show, {project_id: project.id, id: test_case.to_param}
      assigns(:test_case).should eq(test_case)
    end

    it "assigns the requested executions as @executions" do
      sign_in user_of_project
      version = create(:test_case_version, test_case: test_case)
      execution = create(:execution, version: version)
      get :show, {project_id: project.id, id: test_case.to_param}
      assigns(:executions).should eq([execution])
      assigns(:dispenser_executions).should be_a(::Tmt::Dispenser)
    end

    it "assigns the requested versions as @versions" do
      sign_in user_of_project
      version = create(:test_case_version, test_case: test_case)
      get :show, {project_id: project.id, id: test_case.to_param}
      assigns(:versions).should eq([version])
      assigns(:dispenser_versions).should be_a(::Tmt::Dispenser)
    end

    it "saves current test case to member" do
      sign_in user_of_project
      member.current_test_case.should be_nil
      get :show, {project_id: project.id, id: test_case.to_param}
      member.reload.current_test_case.should eq(test_case)
    end

    it_should_not_authorize(self, [:no_logged, :foreign]) do
      get :show, {project_id: project.id, :id => test_case.to_param}
    end

    it "assigns the requested versions as @versions" do
      sign_in user_of_project

      create(:test_case_version_with_revision, test_case_id: test_case.id)
      create(:test_case_version_with_revision, test_case_id: test_case.id)
      get :show, {project_id: project.id, :id => test_case.to_param}
      assigns(:versions).should have(2).items
    end

    it "assigns the requested new_version as @new_version" do
      sign_in user_of_project
      get :show, {project_id: project.id, :id => test_case.to_param}
      assigns(:new_version).should be_a(Tmt::TestCaseVersion)
    end

    describe "assigns the requested last_file_name, last_content and version when" do

      it "when test case has not versions" do
        sign_in user_of_project
        get :show, {project_id: project.id, :id => test_case.to_param}
        assigns(:version).should be_nil
      end

      it "when test case has 3 versions but first isn't active" do
        create(:test_case_version_with_revision, test_case_id: test_case.id).stub(:revision).and_return("git-hash")
        create(:test_case_version_with_revision, test_case_id: test_case.id).stub(:revision).and_return("git-hash")
        version = create(:test_case_version, test_case_id: test_case.id)

        sign_in user_of_project
        get :show, {project_id: project.id, :id => test_case.to_param}
        assigns(:version).should eq(version)
      end

    end
  end

  describe "GET new" do
    it_should_not_authorize(self, [:no_logged, :foreign]) do
      get :new, {project_id: project.id}
    end

    it "assigns a new test_case as @test_case" do
      sign_in user_of_project
      get :new, {project_id: project.id}
      assigns(:test_case).should be_a_new(Tmt::TestCase)
    end
  end

  describe "GET edit" do
    it_should_not_authorize(self, [:no_logged, :foreign]) do
      get :edit, {project_id: project.id, id: test_case.to_param}
    end

    it "assigns the requested test_case as @test_case" do
      sign_in user_of_project
      get :edit, {project_id: project.id, id: test_case.to_param}
      assigns(:test_case).should eq(test_case)
    end

    describe "steward_id" do
      it "should have locked attribute set on true when steward_id is present" do
        sign_in user_of_project
        test_case.update(steward_id: user_of_project.id)
        test_case.locked.should be nil
        get :edit, {project_id: project.id, id: test_case.to_param}
        assigns(:test_case).locked.should be true
      end

      it "should not have locked attribute set on true when steward_id is nil" do
        sign_in user_of_project
        test_case.update(steward_id: nil)
        test_case.locked.should be nil
        get :edit, {project_id: project.id, id: test_case.to_param}
        assigns(:test_case).locked.should be nil
      end
    end

  end

  describe "POST create" do
    it_should_not_authorize(self, [:no_logged, :foreign]) do
      expect {
        post :create, {project_id: project.id, test_case: valid_attributes }
      }.to change(Tmt::TestCase, :count).by(0)
    end

    describe "with sign_in user" do
      before do
        sign_in user
      end

      describe "with valid params" do
        it "creates a new Tmt::TestCase" do
          sign_in admin
          expect {
            post :create, {project_id: project.id, test_case: valid_attributes}
          }.to change(Tmt::TestCase, :count).by(1)
        end

        it "assigns a newly created test_case as @test_case" do
          sign_in admin
          post :create, {project_id: project.id, test_case: valid_attributes}
          assigns(:test_case).should be_a(Tmt::TestCase)
          assigns(:test_case).should be_persisted
        end

        it "redirects to the created test_case" do
          sign_in admin
          post :create, {project_id: project.id, test_case: valid_attributes}
          response.should redirect_to project_test_case_path(project, Tmt::TestCase.last)
        end

        context "with datafile and comment" do
          it "should create test case" do
            sign_in admin
            expect {
              post :create, {
                project_id: project.id,
                test_case: valid_attributes.merge(type_id: type_file.id, version_comment: "Comment", version_datafile: upload_file("main_sequence.seq"))
              }
            }.to change(Tmt::TestCase, :count).by(1)
          end

          it "should create test case when type has variable has_file seted on false" do
            sign_in admin
            expect {
              post :create, {
                project_id: project.id,
                test_case: valid_attributes.merge(version_comment: "Comment", version_datafile: upload_file("main_sequence.seq"))
              }
            }.to change(Tmt::TestCase, :count).by(1)
          end

          it "should create test case version when type has variable has_file seted on false" do
            sign_in admin
            expect {
              post :create, {
                project_id: project.id,
                test_case: valid_attributes.merge(versions_attributes: {"0" => {comment: "Comment", datafile: upload_file("main_sequence.seq")}})
              }
            }.to change(Tmt::TestCaseVersion, :count).by(1)
          end


          it "should create test case version" do
            sign_in admin
            expect {
              post :create, {
                project_id: project.id,
                test_case: valid_attributes.merge(type_id: type_file.id, versions_attributes: {"0" => {comment: "Comment", datafile: upload_file("main_sequence.seq")}})
              }
            }.to change(Tmt::TestCaseVersion, :count).by(1)
          end

          it "should not create test case when comment is empty" do
            sign_in admin
            expect {
              post :create, {
                project_id: project.id,
                test_case: valid_attributes.merge(type_id: type_file.id, versions_attributes: {"0" => {comment: "", datafile: upload_file("main_sequence.seq")}})
              }
            }.to change(Tmt::TestCase, :count).by(0)
          end


          it "should not create test case version when comment is empty" do
            sign_in admin
            expect {
              post :create, {
                project_id: project.id,
                test_case: valid_attributes.merge(type_id: type_file.id, version_comment: "", version_datafile: upload_file("main_sequence.seq"))
              }
            }.to change(Tmt::TestCaseVersion, :count).by(0)
          end

          it "should not create test case version when datafile is empty" do
            sign_in admin
            expect {
              post :create, {
                project_id: project.id,
                test_case: valid_attributes.merge(type_id: type_file.id, version_comment: "Comment")
              }
            }.to change(Tmt::TestCaseVersion, :count).by(0)
          end

        end

      end

      describe "steward_id" do
        it "should set steward_id when user set locked option" do
          sign_in user_of_project
          put :create, {id: test_case.to_param, project_id: project.id, test_case: {name: "Example name", locked: '1'}}
          assigns(:test_case).steward_id.should eq(user_of_project.id)
        end

        it "should not have locked attribute set on true when steward_id is nil" do
          sign_in user_of_project
          put :create, {id: test_case.to_param, project_id: project.id, test_case: {name: "Example name", locked: '0'}}
          assigns(:test_case).steward_id.should be_nil
        end
      end

      describe "with invalid params" do
        it "assigns a newly created but unsaved test_case as @test_case" do
          sign_in admin
          Tmt::TestCase.any_instance.stub(:save).and_return(false)
          post :create, {project_id: project.id, test_case: { "name" => "invalid value" }}
          assigns(:test_case).should be_a_new(Tmt::TestCase)
        end

        it "re-renders the 'new' template" do
          sign_in admin
          Tmt::TestCase.any_instance.stub(:save).and_return(false)
          post :create, {project_id: project.id, test_case: { "name" => "invalid value", project_id: project.id }}
          response.should render_template("new")
        end
      end
    end

    describe "with valid params and custom fields"  do
      let(:custom_fields) do
        {
          string: create(:test_case_custom_field, type_name: :string, project_id: project.id, name: 'Name'),
          text: create(:test_case_custom_field_for_text, project_id: project.id, name: 'description'),
          date: create(:test_case_custom_field_for_date, project_id: project.id, name: 'Deadline'),
          int: create(:test_case_custom_field_for_integer, project_id: project.id, name: 'Amount'),
          enum: create(:test_case_custom_field_for_enumeration, project_id: project.id, name: 'Priorities'),
          bool: create(:test_case_custom_field_for_bool, project_id: project.id, name: 'isActive'),
          bool2: create(:test_case_custom_field_for_bool, project_id: project.id, name: 'isOfficial')
        }
      end

      let(:valid_attributes_with_custom_fields) do
        valid_attributes.merge({
          custom_field_values: {
            custom_fields[:string].id.to_s => {value: "Example"},
            custom_fields[:text].id.to_s => {value: "description of Example"},
            custom_fields[:date].id.to_s => {value: '2014-02-20'},
            custom_fields[:int].id.to_s => {value: 93},
            custom_fields[:bool].id.to_s => {value: true},
            custom_fields[:enum].id.to_s => {
              value: custom_fields[:enum].enumeration.values.last.numerical_value
            }
          }
        })
      end

      {
        string: 'Example',
        text: 'description of Example',
        date: '2014-02-20',
        int: 93,
        bool: true,
        enum: 'high'
      }.each do |key, value|
        it "for #{key} type" do
          ready(test_case, valid_attributes_with_custom_fields)
          sign_in user_of_project

          post :create, {
            project_id: project.id,
            test_case: valid_attributes_with_custom_fields
          }
          custom_field_value = ::Tmt::TestCase.last.custom_field_values.where(custom_field: custom_fields[key]).first
          custom_field_value.value.should eq(value)
        end
      end

    end

  end

  describe "PUT toggle_steward" do
    it "should be active when a test case instance is not locked" do
      sign_in user_of_project
      test_case.update(steward_id: nil)
      put :toggle_steward, {project_id: project.id, id: test_case}
      test_case.reload.steward_id.should eq(user_of_project.id)
      response.should redirect_to(project_test_case_path(project, test_case))
    end

    it "should be active when the steward_id of a test case instance is user_of_project" do
      sign_in user_of_project
      test_case.update(steward_id: user_of_project.id)
      put :toggle_steward, {project_id: project.id, id: test_case}
      test_case.reload.steward_id.should be_nil
    end

    it "should be inactive when the steward_id of a test case instance is not user_of_project" do
      sign_in user_of_project
      test_case.update(steward_id: 0)
      put :toggle_steward, {project_id: project.id, id: test_case}
      test_case.reload.steward_id.should eq(0)
      flash[:alert].should eq('You are not authorized to access this page.')
    end

    it_should_not_authorize(self, [:no_logged, :foreign]) do
      test_case.update(steward_id: nil)
      put :toggle_steward, {project_id: project.id, id: test_case}
      test_case.reload.steward_id.should be_nil
    end
  end

  describe "PUT update" do
    describe "with valid params" do
      it "updates the requested test_case" do
        sign_in user_of_project
        Tmt::TestCase.any_instance.should_receive(:update).with({ "name" => "MyString" })
        put :update, {id: test_case.to_param, project_id: project.id, test_case: { "name" => "MyString" }}
      end

      it_should_not_authorize(self, [:no_logged, :foreign]) do
        put :update, {id: test_case.to_param, project_id: project.id, test_case: { "name" => "MyString" }}
      end

      it "should authorize when test case is deleted" do
        sign_in user_of_project
        test_case.update(deleted_at: Time.now)
        put :update, {id: test_case.to_param, project_id: project.id, test_case: valid_attributes.merge(name: "Example updated name")}
        flash[:alert].should eq('You are not authorized to access this page.')
        test_case.reload.name.should_not eq('Example updated name')
      end

      it "assigns the requested test_case as @test_case" do
        sign_in user_of_project
        put :update, {id: test_case.to_param, project_id: project.id, test_case: valid_attributes}
        assigns(:test_case).should eq(test_case)
      end

      it "redirects to the test_case" do
        sign_in user_of_project
        put :update, {id: test_case.to_param, project_id: project.id, test_case: valid_attributes}
        response.should redirect_to(project_test_case_path(project, test_case))
      end

      describe "steward_id" do
=begin
        it "should not authorize for locked test_case" do
          sign_in user_of_project
          test_case.update(steward_id: 0)
          put :update, {id: test_case.id, project_id: project.id, test_case: { "name" => "MyString" }}
          cancan_not_authorize
        end
=end
        it "should authorize for locked test_case" do
          sign_in user_of_project
          test_case.update(steward_id: user_of_project)
          put :update, {id: test_case.id, project_id: project.id, test_case: { "name" => "MyString" }}
          response.should redirect_to(project_test_case_path(project, test_case))
        end

        it "should set steward_id when user set locked option" do
          sign_in user_of_project
          test_case.update(steward_id: nil)
          test_case.reload.steward_id.should be_nil
          put :update, {id: test_case.to_param, project_id: project.id, test_case: valid_attributes.merge({locked: '1'})}
          test_case.reload.steward_id.should eq(user_of_project.id)
        end

        it "should not have locked attribute set on true when steward_id is nil" do
          sign_in user_of_project
          test_case.update(steward_id: nil)
          test_case.reload.steward_id.should be_nil
          put :update, {id: test_case.to_param, project_id: project.id, test_case: valid_attributes.merge({locked: '0'})}
          test_case.reload.steward_id.should be_nil
        end
      end
    end

    describe "with invalid params" do
      it "assigns the test_case as @test_case" do
        sign_in user_of_project
        # Trigger the behavior that occurs when invalid params are submitted
        Tmt::TestCase.any_instance.stub(:save).and_return(false)
        put :update, {id: test_case.to_param, project_id: project.id, test_case: { "name" => "invalid value" }}
        assigns(:test_case).should eq(test_case)
      end

      it "re-renders the 'edit' template" do
        sign_in user_of_project
        Tmt::TestCase.any_instance.stub(:save).and_return(false)
        put :update, {id: test_case.to_param, project_id: project.id, test_case: { "name" => "invalid value" }}
        response.should render_template("edit")
      end
    end

    describe "with valid params and custom fields"  do
      let(:custom_fields) do
        {
          string: create(:test_case_custom_field, type_name: :string, project_id: project.id, name: 'Name'),
          text: create(:test_case_custom_field_for_text, project_id: project.id, name: 'description'),
          date: create(:test_case_custom_field_for_date, project_id: project.id, name: 'Deadline'),
          int: create(:test_case_custom_field_for_integer, project_id: project.id, name: 'Amount'),
          bool: create(:test_case_custom_field_for_bool, project_id: project.id, name: 'isActive'),
          enum: create(:test_case_custom_field_for_enumeration, project_id: project.id, name: 'Priorities')
        }
      end

      let(:valid_attributes_with_custom_fields) do
        valid_attributes.merge({
          custom_field_values: {
            custom_fields[:string].id.to_s => {value: "Example"},
            custom_fields[:text].id.to_s => {value: "description of Example"},
            custom_fields[:date].id.to_s => {value: '2014-02-20'},
            custom_fields[:int].id.to_s => {value: 93},
            custom_fields[:bool].id.to_s => {value: true},
            custom_fields[:enum].id.to_s => {
              value: custom_fields[:enum].enumeration.values.last.numerical_value
            }
          }
        })
      end

      {
        string: 'Example',
        text: 'description of Example',
        date: '2014-02-20',
        int: 93,
        bool: true,
        enum: 'high'
      }.each do |key, value|
        it "for #{key} type" do
          ready(test_case, valid_attributes_with_custom_fields)

          sign_in user_of_project
          put :update, {project_id: project.id, id: test_case.to_param, test_case: valid_attributes_with_custom_fields}
          custom_field_value = ::Tmt::TestCase.last.custom_field_values.where(custom_field: custom_fields[key]).first
          custom_field_value.value.should eq(value)
        end
      end

    end

  end

  describe "DELETE destroy" do
    before do
      ready(test_case)
    end

    it "destroys the requested test_case" do
      sign_in user_of_project

      delete :destroy, {id: test_case.id, project_id: project.id}
      test_case.reload.deleted_at.should_not be_nil
    end

    it "destroys the requested test_case" do
      sign_in user_of_project

      delete :destroy, {id: test_case.id, project_id: project.id}
      test_case.reload.deleted_at.should_not be_nil
    end

    it "redirects to the test_cases list" do
      sign_in user_of_project

      delete :destroy, {id: test_case.to_param, project_id: project.id}
      response.should redirect_to(project_test_cases_url(project))
    end

    it_should_not_authorize(self, [:no_logged, :foreign]) do
      delete :destroy, {id: test_case.to_param, project_id: project.id}
      test_case.reload.deleted_at.should be_nil
    end

  end
end
