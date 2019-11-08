require 'spec_helper'

describe Oslc::Qm::TestPlan::Query do
  include Support::Oslc

  let(:oliver) do
    test_run.creator
  end

  let(:campaign) { create(:campaign) }

  let(:project) do
    project = campaign.project
    project.add_member(oliver)
    project
  end

  let(:test_run) do
    test_run = create(:test_run, campaign: campaign, name: 'First Test Run')
    create(:execution_for_passed, test_run: test_run)
    test_run
  end

  let(:second_test_run) do
    test_run = create(:test_run, campaign: campaign, description: 'Description of Second Test Run')
    test_case = create(:test_case, project: project, name: 'Testing UI')
    version = create(:test_case_version, test_case: test_case)
    create(:execution, progress: 19, version: version, test_run: test_run)
    test_run
  end

  let(:foreign_test_run) { create(:test_run) }


  def query(syntax)
    Oslc::Qm::TestPlan::Query.new(provider: project).where(syntax)
  end

  before do
    ready(test_run, second_test_run, foreign_test_run)
    Tmt::TestRun.all.should match_array [
      test_run,
      second_test_run,
      foreign_test_run
    ]
  end

  it "should return executions when query syntax is empty" do
    result = query(nil)
    result.should match_array [
      test_run,
      second_test_run
    ]
  end

  it "should return Test Runs for appropriate 'dcterms:identifier' property" do
    identifier = server_url("/oslc/qm/service-providers/#{project.id}/test-plans/#{test_run.id}")
    result = query("dcterms:identifier=\"#{identifier}\"")
    result.should match_array [test_run]
  end

  it "should return Test Runs for appropriate 'dcterms:title' property" do
    result = query("dcterms:title=\"First Test Run\"")
    result.should match_array [test_run]
  end

  it "should return Test Runs for appropriate 'dcterms:description' property" do
    result = query("dcterms:description=\"Description of Second Test Run\"")
    result.should match_array [second_test_run]
  end


  it "should return Test Runs for appropriate 'oslc:serviceProvider' property" do
    provider_url = server_url("/oslc/qm/service-providers/#{project.id}")
    result = query("oslc:serviceProvider=\"#{provider_url}\"")
    result.should match_array [test_run, second_test_run]
  end

  it "should return Test Runs for appropriate 'dcterms:creator' property" do
    user = second_test_run.creator
    user_url = server_url("/oslc/users/#{user.id}")
    result = query("dcterms:creator=<#{user_url}>")
    result.should match_array [
      second_test_run,
    ]
  end

  it "should return Test Runs for appropriate 'dcterms:contributor' property" do
    user = project.users.first
    user_url = server_url("/oslc/users/#{user.id}")
    result = query("dcterms:contributor=<#{user_url}>")
    result.should match_array [
      test_run,
      second_test_run
    ]
  end

  it "should return executions for appropriate 'oslc_qm:usesTestCase' property" do
    test_case_id = test_run.test_case_ids.first
    test_case_url = server_url("/oslc/qm/service-providers/#{project.id}/test-cases/#{test_case_id}")
    result = query("oslc_qm:usesTestCase=<#{test_case_url}>")
    result.should match_array [
      test_run
    ]
  end

  it "should return Test Runs for appropriate 'dcterms:created' property" do
    time = Support::Oslc::Date.new(second_test_run.created_at).iso8601
    result = query("dcterms:created=\"#{time}\"")
    result.should match_array [second_test_run]
  end

  it "should return Test Runs for appropriate 'dcterms:modified' property" do
    time = Support::Oslc::Date.new(test_run.updated_at).iso8601
    result = query("dcterms:modified=\"#{time}\"")
    result.should match_array [test_run]
  end
end
