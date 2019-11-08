require 'spec_helper'

describe Oslc::Automation::Plan::Query do
  include Support::Oslc

  let(:user) do
    user = test_run.creator
    project.add_member(user)
    user
  end

  let(:test_run) { create(:test_run, campaign: create(:campaign, project: project)) }
  let(:version) { create(:test_case_version, test_case: test_case) }
  let(:execution) { create(:execution, progress: 19, version: version, test_run: test_run) }
  let(:test_case) { create(:test_case, project: project, name: 'Testing UI') }
  let(:execution_for_passed) do
    create(:execution_for_passed, test_run: test_run)
  end
  let(:foreign_execution) { create(:execution) }


  let(:project) { create(:project)}

  def query(syntax)
    Oslc::Automation::Plan::Query.new(provider: project).where(syntax)
  end

  before do
    ready(execution, execution_for_passed, foreign_execution)
    Tmt::Execution.all.should match_array [
      execution,
      execution_for_passed,
      foreign_execution
    ]
  end

  it "should return executions when query syntax is empty" do
    result = query(nil)
    result.should match_array [
      execution,
      execution_for_passed
    ]
  end

  it "should return executions for appropriate 'dcterms:identifier' property" do
    identifier = server_url("/oslc/automation/service-providers/#{project.id}/plans/#{execution.id}")
    result = query("dcterms:identifier=\"#{identifier}\"")
    result.should match_array [execution]
  end

  it "should return executions for appropriate 'dcterms:title' property" do
    identifier = server_url("/oslc/automation/service-providers/#{project.id}/plans/#{execution.id}")
    result = query("dcterms:title=\"Testing UI\"")
    result.should match_array [execution]
  end

  it "should return executions for appropriate 'oslc:serviceProvider' property" do
    provider_url = server_url("/oslc/automation/service-providers/#{project.id}")
    result = query("oslc:serviceProvider=\"#{provider_url}\"")
    result.should match_array [execution, execution_for_passed]
  end

  it "should return executions for appropriate 'dcterms:creator' property" do
    user_url = server_url("/oslc/users/#{user.id}")
    result = query("dcterms:creator=<#{user_url}>")
    result.should match_array [
      execution,
      execution_for_passed
    ]
  end

  it "should return executions for appropriate 'dcterms:contributor' property" do
    user_url = server_url("/oslc/users/#{user.id}")
    result = query("dcterms:contributor=<#{user_url}>")
    result.should match_array [
      execution,
      execution_for_passed
    ]
  end

  it "should return executions for appropriate 'oslc_qm:runsTestCase' property" do
    test_case_id = execution.version.test_case_id
    test_case_url = server_url("/oslc/qm/service-providers/#{project.id}/test-cases/#{test_case_id}")
    result = query("oslc_qm:runsTestCase=<#{test_case_url}>")
    result.should match_array [
      execution
    ]
  end

  it "should return executions for appropriate 'dcterms:created' property" do
    time = Support::Oslc::Date.new(execution_for_passed.created_at).iso8601
    result = query("dcterms:created=\"#{time}\"")
    result.should match_array [execution_for_passed]
  end

  it "should return executions for appropriate 'dcterms:modified' property" do
    time = Support::Oslc::Date.new(execution.updated_at).iso8601
    result = query("dcterms:modified=\"#{time}\"")
    result.should match_array [execution]
  end
end
