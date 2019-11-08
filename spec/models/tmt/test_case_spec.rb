require 'spec_helper'

describe Tmt::TestCase do
  let(:project) { create(:project, name: "Project name") }

  let(:creator) { create(:user, name: "u1") }

  let(:type_without_file) { create(:test_case_type) }

  let(:valid_test_case) do
    {
      name: "TmtTestCase1",
      creator: creator,
      project: project,
      type_id: type_without_file.id
    }
  end

  let(:test_case) { create(:test_case, valid_test_case) }

  it "has many versions" do
    version = create(:test_case_version, test_case: test_case)
    next_version = create(:test_case_version_with_revision, test_case: test_case)
    foreign_version = create(:test_case_version)
    test_case.versions.should match_array([version, next_version])
  end

  it "has many executions" do
    version = create(:test_case_version, test_case: test_case)
    next_version = create(:test_case_version_with_revision, test_case: test_case)
    foreign_version = create(:test_case_version)
    execution = create(:execution, version: version)
    next_execution = create(:execution, version: next_version)
    foreign_execution = create(:execution, version: foreign_version)
    test_case.executions.should match_array([execution, next_execution])
  end

  it "validates factory" do
    expect do
      create(:test_case)
    end.to change(::Tmt::TestCase, :count).by(1)
  end

  it "should include steward_id value" do
    test_case.update(steward_id: creator.id)
    test_case.reload.steward.should eq(creator)
  end

  it "should not valid the test case with empty name" do
    ready(test_case)
    test_case.name = ""
    test_case.should_not be_valid
  end

  it "should return properly name of project" do
    test_case.project_name.should eq("Project name")
  end

  it "can valid attribute name" do
    Tmt::Cfg.first.update(max_name_length: 20)
    build(:test_case, name: 'a'*15).should be_valid
  end

  it "cannot valid attribute name" do
    Tmt::Cfg.first.update(max_name_length: 20)
    build(:test_case, name: 'a'*23).should_not be_valid
  end

  describe "for type_id attribute" do
    it "validates when type id existing" do
      expect do
        create(:test_case, type_id: type_without_file.id)
      end.to change(Tmt::TestCase, :count).by(1)
    end

    it "doesn't validate when type doesn't exist" do
      expect do
        create(:test_case, type_id: 0)
      end.to raise_error(ActiveRecord::RecordInvalid, /Type id '0' doesn't exist!/)
    end

    it "doesn't validate when type is blank" do
      expect do
        create(:test_case, type_id: nil)
      end.to raise_error(ActiveRecord::RecordInvalid, /Type id '' doesn't exist!/)
    end
  end

  it "should return properly name of creator" do
    test_case.creator_name.should eq(creator.name)
  end

  describe "for custom fields attribute" do
    let(:category) do
      create(:test_case_custom_field, project_id: project.id)
    end

    let(:valid_attributes) do
      category_id = category.id
      valid_test_case.merge({
        custom_field_values: {
          category_id => {
            'value' => "Example Category"
          }
        }
      })
    end

    it "should allowed set value for category" do
      test_case = Tmt::TestCase.create!(valid_attributes)
      test_case.reload_custom_field_values
      test_case.update(valid_attributes)
      test_case.custom_field_values.pluck(:string_value).should include("Example Category")
    end

    it "should not allowed set value for category with lower limit set 100" do
      test_case = Tmt::TestCase.create!(valid_attributes)
      category.update(lower_limit: 100, upper_limit: nil)
      test_case.reload
      test_case.reload_custom_field_values
      expect do
        test_case.update!(valid_attributes)
      end.to raise_error(/Custom Field Value class is incorrectly/)
    end

  end

  it "should generate a activity entry once its name is changed" do
    expect {
      test_case.name = "TmtTestCase1a"
      test_case.save
    }.to change(test_case.user_activities, :count).by(1)
  end

  it "should generate a activity entry once its description is changed" do
    expect {
      test_case.description = "something"
      test_case.save
    }.to change(test_case.user_activities, :count).by(1)
  end

  describe "for custom fields attribute" do
    let(:category) do
      create(:test_case_custom_field, project_id: project.id, name: :category)
    end

    let(:valid_attributes) do
        category_id = category.id
        valid_test_case.merge({
          custom_field_values: {
            category_id => {
              'value' => "Other Category"
            }
          }
        })
      end

    it "should generate a activity entry once any a custom field is changed" do
      expect {
        test_case.reload
        test_case.reload_custom_field_values
        test_case.update(valid_attributes)
        test_case.save
      }.to change(test_case.user_activities, :count).by(1)
    end

  end

  it "#set_deleted" do
    ready(test_case)
    test_case.deleted_at.should be_nil
    test_case.set_deleted
    test_case.deleted_at.should_not be_nil
  end

  it ".undeleted" do
    test_cases = [
      create(:test_case, deleted_at: nil),
      create(:test_case, deleted_at: Time.now),
      create(:test_case, deleted_at: nil)
    ]
    Tmt::TestCase.undeleted.should match_array([test_cases[0], test_cases[2]])
  end

end
