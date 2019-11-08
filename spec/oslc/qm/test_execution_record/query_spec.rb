require 'spec_helper'

describe Oslc::Qm::TestExecutionRecord::Query do
  include Support::Oslc

  let(:project) do
    project = create(:project)
    project.add_member(user)
    project
  end

  let(:user) do
    user = create(:user)
    project.add_member(user)
    user
  end

  let(:test_run) do
    test_run = execution.test_run
    test_run.executor_id =  test_run.creator_id
    test_run.save(validate: false)
    test_run
  end

  let(:version) { execution.version }

  let(:test_case) do
    test_case = version.test_case
    test_case.update(project: project)
    test_case
  end

  let(:execution) { create(:execution, progress: 19) }
  let(:execution_progress_23) { create(:execution, progress: 23, test_run: test_run) }
  let(:execution_for_passed) do
    create(:execution_for_passed, test_run: test_run, comment: 'Execution: Passed')
  end

  let(:foreign_execution) { create(:execution) }

  let(:project) { test_run.project}

  def query(syntax)
    Oslc::Qm::TestExecutionRecord::Query.new(provider: project).where(syntax)
  end

  before do
    ready(execution, execution_progress_23, execution_for_passed, project, foreign_execution, test_case)
    Tmt::Execution.all.should match_array [
      execution,
      execution_progress_23,
      execution_for_passed,
      foreign_execution
    ]
  end

  it "should return executions when query syntax is empty" do
    result = query(nil)
    result.should match_array [
      execution,
      execution_progress_23,
      execution_for_passed
    ]
  end

  it "should return executions with appropriate identifier" do
    identifier = server_url("/oslc/qm/service-providers/#{project.id}/test-execution-records/#{execution_progress_23.id}")
    result = query("dcterms:identifier=\"#{identifier}\"")
    result.should match_array [execution_progress_23]
  end

  it "should return executions for appropriate 'dcterms:title' property" do
    result = query("dcterms:title=\"Execution #{execution_for_passed.comment}\"")
    result.should match_array [
      execution_for_passed
    ]
  end

  it "should return executions for appropriate 'dcterms:creator' property" do
    creator_id = execution.test_run.creator.id
    url = server_url("/oslc/users/#{creator_id}")
    result = query("dcterms:creator=<#{url}>")
    result.should match_array [
      execution,
      execution_progress_23,
      execution_for_passed
    ]
  end

  it "should return executions for appropriate 'dcterms:contributor' property" do
    executor_id = execution.test_run.executor.id
    url = server_url("/oslc/users/#{executor_id}")
    result = query("dcterms:contributor=<#{url}>")
    result.should match_array [
      execution,
      execution_progress_23,
      execution_for_passed
    ]
  end

  it "should return executions for appropriate 'oslc:serviceProvider' property" do
    url = server_url("/oslc/qm/service-providers/#{project.id}")
    result = query("oslc:serviceProvider=\"#{url}\"")
    result.should match_array [
      execution,
      execution_for_passed,
      execution_progress_23
    ]
  end

  it "should return executions for appropriate 'oslc_qm:reportsOnTestPlan' property" do
    url = server_url("/oslc/qm/service-providers/#{project.id}/test-plans/#{execution.test_run.id}")
    result = query("oslc_qm:reportsOnTestPlan=<#{url}>")
    result.should match_array [
      execution,
      execution_for_passed,
      execution_progress_23
    ]
  end

  it "should return executions for appropriate 'oslc_qm:runsTestCase' property" do
    test_case_id = execution.test_case.id
    url = server_url("/oslc/qm/service-providers/#{project.id}/test-cases/#{test_case_id}")
    result = query("oslc_qm:runsTestCase=<#{url}>")
    result.should match_array [
      execution
    ]
  end

  it "should return executions for appropriate 'oslc:instanceShape' property" do
    url = server_url('/oslc/qm/resource-shapes/test-execution-record')
    result = query("oslc:instanceShape=<#{url}>")
    result.should match_array [
      execution,
      execution_for_passed,
      execution_progress_23
    ]
    result = query("oslc:instanceShape=\"\"")
    result.should match_array []
  end

  it "should return executions for appropriate 'dcterms:created' property" do
    time = Support::Oslc::Date.new(execution_progress_23.created_at).iso8601
    result = query("dcterms:created=\"#{time}\"")
    result.should match_array [execution_progress_23]
  end

  it "should return executions for appropriate 'dcterms:modified' property" do
    time = Support::Oslc::Date.new(execution_for_passed.updated_at).iso8601
    result = query("dcterms:modified=\"#{time}\"")
    result.should match_array [execution_for_passed]
  end

end
