require 'spec_helper'

[
  [Tmt::TestCaseCustomField, :test_case],
  [Tmt::TestRunCustomField, :test_run]
].each do |class_name, prefix|
  describe class_name do
    let(:project) { create(:project) }
    let(:creator) { create(:user) }
    let(:test_case_run) do
      case prefix
      when :test_run
        create(:test_run, creator: creator)
      when :test_case
        create(:test_case, project: project, creator: creator)
      else

      end
    end
    let(:klass) { class_name }

    let(:valid_attributes) do
      {
        project_id: project.id,
        type_name: :text,
        description: "description of Category",
        name: "category"
      }
    end

    let(:custom_field) { klass.create(valid_attributes) }

    before do
      Tmt::Cfg.first.update(max_name_length: 35)
    end

    it "should valid new custom field" do
      klass.new(valid_attributes).should be_valid
    end

    it "should don't valid when name is nil" do
      attributes = valid_attributes
      attributes[:name] = nil
      klass.new(attributes).should_not be_valid
    end

    it "should don't valid when name contains one of the following characters: space, dot, >" do
      attributes = valid_attributes
      attributes[:name] = 'example'
      klass.new(attributes).should be_valid
      attributes[:name] = 'exam.ple'
      klass.new(attributes).should_not be_valid
      attributes[:name] = 'exam>ple'
      klass.new(attributes).should_not be_valid
      klass.create(attributes).errors[:name].should eq ["have to consist any of the following characters: a-z A-Z 0-9 _ - "]
      attributes[:name] = 'ąółĄŻĆöäü'
      klass.new(attributes).should be_valid
    end


    it "should don't valid when type is nil" do
      attributes = valid_attributes
      attributes[:type_name] = nil
      klass.new(attributes).should_not be_valid
    end

    it "should not create record when length of name is greater than 35" do
      expect do
        klass.create!(valid_attributes.merge({name: 'a'*36}))
      end.to raise_error(ActiveRecord::RecordInvalid, /does not have length between 1 and 35/)
    end

    it "should create record when length of name is lower than 36" do
      expect do
        klass.create(valid_attributes.merge({name: 'a'*35}))
      end.to change(klass, :count).by(1)
    end

    it "should don't valid when type_name is 'example' (doesn't defined by model)" do
      attributes = valid_attributes
      attributes[:type_name] = 'example'
      expect do
        klass.new(attributes).save!
      end.to raise_error(ActiveRecord::RecordInvalid)
    end

    it "should properly get name of type" do
      custom_field.type_name.should eq(:text)
    end

    it ".select_for_project" do
      custom_field_for_pattern = klass.create(name: 'ForPattern', type_name: :string, description: 'description', project: nil)
      custom_field_for_current = klass.create(name: 'ForCurrentProject', type_name: :string, description: 'description', project: project)
      custom_field_for_foreign = klass.create(name: 'ForForeignProject', type_name: :string, description: 'description', project: create(:project))
      klass.select_for_project(project).should_not include custom_field_for_pattern
      klass.select_for_project(project).should include custom_field_for_current
      klass.select_for_project(project).should_not include custom_field_for_foreign
    end

    describe "#after_save" do
      it "should create custom field value for objects of selected project" do
        test_run_case = create(prefix)
        test_run_case.custom_field_values.should be_empty
        project = test_run_case.project
        custom_field = klass.create(name: 'ForProject', type_name: :string, description: 'description', project: project)
        test_run_case.reload.custom_field_values.should have(1).item
        custom_field.update(name: 'NewName')
        custom_field.reload.name.should eq('NewName')
        test_run_case.reload.custom_field_values.should have(1).item
      end

      it "should not create custom field value for objects when project is not selected" do
        test_run_case = create(prefix)
        test_run_case.custom_field_values.should be_empty
        custom_field = klass.create(name: 'ForProject', type_name: :string, description: 'description', project: nil)
        test_run_case.reload.custom_field_values.should be_empty
      end
    end

    describe "#after_destroy" do
      it "should destroy custom field value for objects of selected project" do
        test_run_case = create(prefix)
        project = test_run_case.project
        custom_field = klass.create(name: 'ForProject', type_name: :string, description: 'description', project: project)
        test_run_case.reload.custom_field_values.should_not be_empty
        expect do
          custom_field.destroy
        end.to change(custom_field.class, :count).by(-1)
        test_run_case.reload.custom_field_values.should be_empty
      end

      it "should not destroy custom field value for objects when project is not selected" do
        test_run_case = create(prefix)
        custom_field = klass.create(name: 'ForProject', type_name: :string, description: 'description', project: nil)
        test_run_case.reload.custom_field_values.should be_empty
        expect do
          custom_field.destroy
        end.to change(custom_field.class, :count).by(-1)
        test_run_case.reload.custom_field_values.should be_empty
      end
    end

    describe "#value_for" do
      it "should return nil when test_case don't exist" do
        custom_field.value_for(0).should be_nil
      end

      it "should return 'Test value' when test_case don't exist" do
        ready(custom_field)
        test_case_run.custom_field_values.create!(custom_field_id: custom_field.id, value: "TestValue")
        custom_field.value_for(test_case_run.id).should eq("TestValue")
      end
    end

    describe "project_id" do
      it "should create custom field for empty project" do
        expect do
          klass.create!(name: 'NewCustomField', type_name: :int, project_id: nil)
        end.to_not raise_error
      end

      it "should create custom field for existing project" do
        project = create(:project)
        expect do
          klass.create!(name: 'NewCustomField', type_name: :int, project_id: project.id)
        end.to_not raise_error
      end

      it "should not create custom field for not existing project" do
        project = create(:project)
        expect do
          klass.create!(name: 'NewCustomfield', type_name: :int, project_id: 0)
        end.to raise_error
      end

      it "should be updated from nil to existing project" do
        project = create(:project)
        custom_field = klass.create!(name: 'NewCustomField', type_name: :int, project_id: nil)
        custom_field.id.should_not be_nil

        expect do
          custom_field.update(project_id: project.id)
        end.to_not raise_error
        custom_field.reload.project_id.should eq(project.id)
      end

      it "should not be updated from existing project to another existing project" do
        project = create(:project)
        project_next = create(:project)
        custom_field = klass.create!(name: 'NewCustomField', type_name: :int, project_id: project.id)
        custom_field.id.should_not be_nil

        expect do
          custom_field.update!(project_id: project_next.id)
        end.to raise_error(ActiveRecord::RecordInvalid)
        custom_field.reload.project_id.should eq(project.id)
      end

      it "should not be updated from existing project to nil" do
        project = create(:project)
        custom_field = klass.create!(name: 'NewCustomField', type_name: :int, project_id: project.id)
        custom_field.id.should_not be_nil

        expect do
          custom_field.update!(project_id: nil)
        end.to raise_error(ActiveRecord::RecordInvalid)
        custom_field.reload.project_id.should eq(project.id)
      end

    end

    describe "for type string" do
      let(:valid_attributes) do
        {
          project_id: project.id,
          type_name: :string,
          description: "description of String",
          upper_limit: 10,
          default_value: 'example',
          name: "string"
        }
      end

      let(:custom_field) { klass.create(valid_attributes) }

      it "should create new record" do
        klass.create(valid_attributes).errors.should be_empty
      end

      context "for attribute upper_limit" do
        it "should create new record without upper limit" do
          klass.create(valid_attributes.merge({upper_limit: nil})).errors.should be_empty
        end

        it "should not create new record with invalid upper_limit" do
          klass.create(valid_attributes.merge({upper_limit: "string"})).errors.should be_empty
        end

        it "should not create new record with minus upper_limit" do
          klass.create(valid_attributes.merge({upper_limit: -10})).errors.should_not be_empty
        end
      end

      context "for attribute lower_limit" do
        it "should create new record without lower limit" do
          klass.create(valid_attributes.merge({lower_limit: nil})).errors.should be_empty
        end

        it "should create new record with 'string' value of lower_limit" do
          entry = klass.new(valid_attributes.merge({lower_limit: "string"}))
          entry.save
          entry.errors.should be_empty
          entry.lower_limit.should be_zero
        end

        it "should not create new record with minus lower_limit" do
          klass.create(valid_attributes.merge({lower_limit: -10})).errors.should_not be_empty
        end

      end

      context "for attribute default_value" do
        it "should create new record without default_value" do
          klass.create(valid_attributes.merge({lower_limit: nil})).errors.should be_empty
        end

        it "should not create new record with string of default_value" do
          klass.create(valid_attributes.merge({default_value: "OK"})).errors.should be_empty
        end

        it "should not create new record with number of default_value" do
          klass.create(valid_attributes.merge({default_value: -10})).errors.should be_empty
        end

      end
    end

    describe "for type text" do
      let(:valid_attributes) do
        {
          project_id: project.id,
          type_name: :text,
          description: "description of Text",
          upper_limit: 10,
          default_value: 'example',
          name: "test"
        }
      end

      let(:custom_field) { klass.create(valid_attributes) }

      it "should create new record" do
        klass.create(valid_attributes).errors.should be_empty
      end

      context "for attribute upper_limit" do
        it "should create new record without upper limit" do
          klass.create(valid_attributes.merge({upper_limit: nil})).errors.should be_empty
        end

        it "should not create new record with invalid upper_limit" do
          entry = klass.new(valid_attributes.merge({upper_limit: "string"}))
          entry.save
          entry.errors.should be_empty
          entry.upper_limit.should be_zero
        end

        it "should not create new record with minus upper_limit" do
          klass.create(valid_attributes.merge({upper_limit: -10})).errors.should_not be_empty
        end
      end

      context "for attribute lower_limit" do
        it "should create new record without lower limit" do
          klass.create(valid_attributes.merge({lower_limit: nil})).errors.should be_empty
        end

        it "should create new record 'string' value of lower_limit" do
          entry = klass.new(valid_attributes.merge({lower_limit: "string"}))
          entry.save
          entry.errors.should be_empty
          entry.lower_limit.should be_zero
        end

        it "should not create new record with minus lower_limit" do
          klass.create(valid_attributes.merge({lower_limit: -10})).errors.should_not be_empty
        end
      end

      context "for attribute default_value" do
        it "should create new record without default_value" do
          klass.create(valid_attributes.merge({default_value: nil})).errors.should be_empty
        end

        it "should not create new record with string of default_value" do
          klass.create(valid_attributes.merge({default_value: "OK"})).errors.should be_empty
        end

        it "should create new record with number of default_value" do
          klass.create(valid_attributes.merge({default_value: -10})).errors.should be_empty
        end

      end
    end

    describe "for type intiger" do
      let(:valid_attributes) do
        {
          project_id: project.id,
          type_name: :int,
          description: "description of Int",
          upper_limit: 10,
          lower_limit: -10,
          default_value: -1,
          name: "integer"
        }
      end

      let(:custom_field) { klass.create(valid_attributes) }

      it "should create new record" do
        klass.create(valid_attributes).errors.should be_empty
      end

      context "for attribute upper_limit" do
        it "should create new record without upper limit" do
          klass.create(valid_attributes.merge({upper_limit: nil})).errors.should be_empty
        end

        it "should create new record with valid upper_limit" do
          klass.create(valid_attributes.merge({upper_limit: 11})).errors.should be_empty
        end

        it "should create new record with string of upper_limit" do
          entry = klass.new(valid_attributes.merge({upper_limit: 'invalid'}))
          entry.save
          entry.errors.should be_empty
          entry.upper_limit.should be_zero
        end
      end

      context "for attribute lower_limit" do
        it "should create new record without lower limit" do
          klass.create(valid_attributes.merge({lower_limit: nil})).errors.should be_empty
        end

        it "should not create new record with minus lower_limit" do
          klass.create(valid_attributes.merge({lower_limit: -11})).errors.should be_empty
        end

      end

      context "for attribute default_value" do
        it "should create new record without default_value" do
          klass.create(valid_attributes.merge({default_value: nil})).errors.should be_empty
        end

        it "should create new record with number of default_value" do
          klass.create(valid_attributes.merge({default_value: -11})).errors.should be_empty
        end

      end
    end

    describe "for type date" do
      let(:valid_attributes) do
        {
          project_id: project.id,
          type_name: :date,
          description: "description of Date",
          default_value: '2013-06-01',
          name: "Date"
        }
      end

      let(:custom_field) { klass.create(valid_attributes) }

      it "should create new record" do
        klass.create(valid_attributes).errors.should be_empty
      end

      context "for attribute upper_limit" do
        it "should create new record without upper limit value" do
          klass.create(valid_attributes.merge({upper_limit: nil})).errors.should be_empty
        end

        it "should not create new record with string upper_limit value" do
          entry = klass.new(valid_attributes.merge({upper_limit: "string"}))
          entry.save
          entry.errors.should_not be_empty
        end

        it "should not create new record with integer upper_limit value" do
          klass.create(valid_attributes.merge({upper_limit: 1})).errors.should_not be_empty
        end
      end

      context "for attribute lower_limit" do
        it "should create new record without lower limit value" do
          klass.create(valid_attributes.merge({lower_limit: nil})).errors.should be_empty
        end

        it "should not create new record with string of lower_limit" do
          klass.create(valid_attributes.merge({lower_limit: "example"})).errors.should_not be_empty
        end

        it "should not create new record with number of lower_limit value" do
          klass.create(valid_attributes.merge({lower_limit: 1})).errors.should_not be_empty
        end

      end

      context "for attribute default_value" do
        it "should create new record without default_value" do
          klass.create(valid_attributes.merge({default_value: nil})).errors.should be_empty
        end

        it "should not create new record with string of default_value" do
          klass.create(valid_attributes.merge({default_value: "invalid"})).errors.should_not be_empty
        end

        it "should not create new record with number of default_value" do
          klass.create(valid_attributes.merge({default_value: 1})).errors.should_not be_empty
        end

      end
    end

    describe "for type bool" do
      let(:valid_attributes) do
        {
          project_id: project.id,
          type_name: :bool,
          description: "description of Bool",
          default_value: 't',
          name: "Bool"
        }
      end

      let(:custom_field) { klass.create(valid_attributes) }

      it "should create new record" do
        klass.create(valid_attributes).errors.should be_empty
      end

      context "for attribute upper_limit" do
        it "should create new record without upper limit" do
          klass.create(valid_attributes.merge({upper_limit: nil})).errors.should be_empty
        end

        it "should not create new record with string upper_limit" do
          klass.create(valid_attributes.merge({upper_limit: "invalid"})).errors.should_not be_empty
        end

      end

      context "for attribute lower_limit" do
        it "should create new record without lower limit" do
          klass.create(valid_attributes.merge({lower_limit: nil})).errors.should be_empty
        end

        it "should not create new record with string of lower_limit" do
          klass.create(valid_attributes.merge({lower_limit: "example"})).errors.should_not be_empty
        end
      end

      context "for attribute default_value" do
        it "should create new record without default_value" do
          klass.create(valid_attributes.merge({default_value: nil})).errors.should be_empty
        end

        it "should not create new record with string of default_value" do
          klass.create(valid_attributes.merge({default_value: "invalid"})).errors.should_not be_empty
        end

      end

    end

    describe "for type enumeration" do
      let(:enumeration) { create(:enumeration_for_priorities) }
      let(:valid_attributes) do
        {
          project_id: project.id,
          type_name: :enum,
          description: "description of Enumeration",
          enumeration_id: enumeration.id,
          name: "Enumeration"
        }
      end

      let(:custom_field) { klass.create(valid_attributes) }

      it "should create for factory" do
        expect do
          create(:test_run_custom_field_for_enumeration)
        end.to_not raise_error
      end

      it "should create new record" do
        klass.create(valid_attributes).errors.should be_empty
        klass.last.enumeration.should eq enumeration
      end

      it "should not create new record when enumeration is used by other test case" do
        enumeration = create(:enumeration_for_test_case)
        expect do
          create(:test_run_custom_field_for_enumeration, enumeration_id: enumeration.id)
        end.to raise_error(/was used by other object/)
      end

      it "should not create new record when enumeration is used by other test run" do
        enumeration = create(:enumeration_for_test_run)
        expect do
          create(:test_run_custom_field_for_enumeration, enumeration_id: enumeration.id)
        end.to raise_error(/Enumeration was used by other object/)
      end

      it "should not create new record when enumeration is not defined" do
        expect do
          create(:test_run_custom_field_for_enumeration, enumeration_id: nil)
        end.to raise_error(/Enumeration doesn't exist/)
      end

      context "for attribute upper_limit" do
        it "should create new record without upper limit" do
          klass.create(valid_attributes.merge({upper_limit: nil})).errors.should be_empty
        end

        it "should not create new record with string upper_limit" do
          klass.create(valid_attributes.merge({upper_limit: "invalid"})).errors.should_not be_empty
        end

      end

      context "for attribute lower_limit" do
        it "should create new record without lower limit" do
          klass.create(valid_attributes.merge({lower_limit: nil})).errors.should be_empty
        end

        it "should not create new record with string of lower_limit" do
          klass.create(valid_attributes.merge({lower_limit: "example"})).errors.should_not be_empty
        end
      end

      context "for attribute default_value" do
        it "should create new record without default_value" do
          klass.create(valid_attributes.merge({default_value: nil})).errors.should be_empty
        end

        it "should not create new record with string of default_value" do
          klass.create(valid_attributes.merge({default_value: "invalid"})).errors.should_not be_empty
        end

      end

      context "for attribute enumeration_id" do
        it "should not create new record without enumeration_id" do
          klass.create(valid_attributes.merge({enumeration_id: nil})).errors.should_not be_empty
        end

        it "should not create new record with  invalid enumeration_id" do
          klass.create(valid_attributes.merge({enumeration_id: 0})).errors.should_not be_empty
        end
      end

    end

    it "shouldn't change type of custom field" do
      expect do
        custom_field.update!({type_name: :string})
      end.to raise_error(ActiveRecord::RecordInvalid, /You can't change type/)
    end
  end
end
