require 'spec_helper'

describe Oslc::Qm::TestCase::Query do
  include Support::Oslc

  let(:project) do
    project = create(:project)
    project.add_member(user)
    project.add_member(john)
    project
  end

  let(:user) do
    create(:user)
  end

  let(:peter) do
    create(:user, name: 'Peter')
  end

  let(:john) do
    create(:user)
  end

  let(:test_case_with_version) do
    test_case = create(:test_case,
      creator: john,
      project: project,
      name: 'Test Case with version',
      description: 'Resource with Version'
    )
    create(:test_case_version, test_case: test_case)
    test_case
  end

  let(:test_case) do
    create(:test_case,
      project: project,
      creator: user,
      description: 'Resource without version'
    )
  end

  let(:foreign_test_case) do
    create(:test_case)
  end

  def query(syntax)
    Oslc::Qm::TestCase::Query.new(provider: project).where(syntax)
  end

  before do
    ready(project, user, test_case, foreign_test_case, test_case_with_version)
    Tmt::TestCase.all.should match_array [
      test_case,
      test_case_with_version,
      foreign_test_case
    ]
  end

  it "should return executions when query syntax is empty" do
    result = query(nil)
    result.should match_array [
      test_case,
      test_case_with_version
    ]
  end

  it "should return test cases with appropriate 'dcterms:identifier' property" do
    identifier = server_url("/oslc/qm/service-providers/#{project.id}/test-cases/#{test_case_with_version.id}")
    result = query("dcterms:identifier=\"#{identifier}\"")
    result.should match_array [test_case_with_version]
  end

  it "should return test cases for appropriate 'dcterms:description' property" do
    result = query("dcterms:description=\"#{test_case.description}\"")
    result.should match_array [test_case]
  end

  it "should return test cases for appropriate 'dcterms:title' property" do
    result = query("dcterms:title=\"#{test_case_with_version.name}\"")
    result.should match_array [test_case_with_version]
  end

  it "should return test cases for appropriate 'oslc:serviceProvider' property" do
    url = server_url("/oslc/qm/service-providers/#{project.id}")
    result = query("oslc:serviceProvider=\"#{url}\"")
    result.should match_array [
      test_case,
      test_case_with_version
    ]
  end

  it "should return test cases for appropriate 'oslc:instanceShape' property" do
    url = server_url('/oslc/qm/resource-shapes/test-case')
    result = query("oslc:instanceShape=<#{url}>")
    result.should match_array [
      test_case,
      test_case_with_version
    ]
    result = query("oslc:instanceShape=\"\"")
    result.should match_array []
  end

  it "should return test cases for appropriate 'dcterms:creator' property" do
    user_url = server_url("/oslc/users/#{john.id}")
    result = query("dcterms:creator=<#{user_url}>")
    result.should match_array [
      test_case_with_version
    ]
  end

  it "should return test cases for appropriate 'dcterms:creator' property (scope version)" do
    test_case_with_version.update(creator: peter)
    result = query("dcterms:creator{foaf:name=\"#{peter.name}\"}")
    result.should match_array [test_case_with_version]
  end

  it "should return test cases for appropriate 'dcterms:creator' property when Peter is member of project" do
    project.add_member(peter)
    result = query("dcterms:contributor{foaf:name=\"#{peter.name}\"}")
    result.should match_array [test_case, test_case_with_version]
    Tmt::Member.where(user: peter).delete_all
    result = query("dcterms:contributor{foaf:name=\"#{peter.name}\"}")
    result.should match_array []
  end

  it "should return test cases for appropriate'oslc_qm:usesTestScript' property (scope version)" do
    version = test_case_with_version.versions[0]
    test_script_url = server_url("/oslc/qm/service-providers/#{project.id}/test-scripts/#{version.id}")
    result = query("oslc_qm:usesTestScript{dcterms:identifier=\"#{test_script_url}\"}")
    result.should match_array [test_case_with_version]
  end

  it "should return test cases for appropriate'oslc_qm:usesTestScript' property" do
    version = test_case_with_version.versions[0]
    test_script_url = server_url("/oslc/qm/service-providers/#{project.id}/test-scripts/#{version.id}")
    result = query("oslc_qm:usesTestScript=<#{test_script_url}>")
    result.should match_array [test_case_with_version]
  end

  it "should return test cases for appropriate'dcterms:contributor' property" do
    user_url = server_url("/oslc/users/#{john.id}")
    result = query("dcterms:contributor=<#{user_url}>")
    result.should match_array [
      test_case,
      test_case_with_version
    ]
  end

  it "should return test cases for appropriate 'dcterms:created' property" do
    time = Support::Oslc::Date.new(test_case.created_at).iso8601
    result = query("dcterms:created=\"#{time}\"")
    result.should match_array [test_case]
  end

  it "should return test cases for appropriate 'dcterms:modified' property" do
    time = Support::Oslc::Date.new(test_case.updated_at).iso8601
    result = query("dcterms:modified=\"#{time}\"")
    result.should match_array [test_case]
  end

end
