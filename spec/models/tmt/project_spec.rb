require 'spec_helper'

describe Tmt::Project do
  let(:user) { create(:user, name: "John") }
  let(:project) { create(:project) }
  let(:project1) { create(:project) }
  let(:project2) { create(:project) }

  it "should properly save new project" do
    expect do
      build(:project).save
    end.to_not raise_error
  end

  [
    "example",
    '12',
    "eXample",
    "Test-Case",
    "Project 12",
    "Project - 21'",
    "a",
    ".",
    "Project ver 2.0",
    "[Project]*'&*'",
    "óżął",
    "[Project]",
  ].each do |name|
    it "should properly valid project for name #{name}" do
      build(:project, name: name).should be_valid
    end
  end

  it "can valid attribute name" do
    Tmt::Cfg.first.update(max_name_length: 20)
    build(:project, name: 'a'*15).should be_valid
  end

  it "cannot valid attribute name" do
    Tmt::Cfg.first.update(max_name_length: 20)
    build(:project, name: 'a'*30).should_not be_valid
  end

  it "should create only for uniquess name" do
    build(:project, name: "Example").should be_valid
    create(:project, name: "Example")
    build(:project, name: "Example").should_not be_valid
  end

  [
    "",
    nil
  ].each do |name|
    it "should not properly valid project for name #{name}" do
      build(:project, name: name).should_not be_valid
    end
  end

  it "should return properly name of creator" do
    create(:project, creator_id: user.id).creator_name.should eq(user.name)
  end

  it "should add new member into project" do
    project.add_member(user)
    project.members.first.user.should eq(user)
  end

  it "#has_open_campaign with result true" do
    create(:campaign, project: project)
    project.has_open_campaigns?.should be true
  end

  it "#has_open_campaign with result false" do
    project.has_open_campaigns?.should be false
  end

  it "#user_projects when user has access into 2 project from 3" do
    project.add_member(user)
    project2.add_member(user)
    Tmt::Project.user_projects(user).should eq([project, project2])
  end

  it "#user_projects when user is nil" do
    Tmt::Project.user_projects(nil).should be_empty
  end

  it "has list of all test case versions" do
    project
    test_case = create(:test_case, project_id: project.id)
    create(:test_case_version, test_case: test_case)
    create(:test_case_version, test_case: test_case, datafile: ::CommonHelper.uploaded_file('short.seq'))
    create(:test_case, project_id: project1.id)
    create(:test_case_version, test_case: create(:test_case, project_id: project1.id))
    project.test_case_versions.should have(2).items
    project.test_case_versions.should eq(test_case.versions)
  end

end
