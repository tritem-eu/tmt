require 'spec_helper'

describe Oslc::Automation::Request::Query do
  include Support::Oslc

  let(:project) do
    project = create(:project)
    project.add_member(user)
    project
  end

  let(:user) do
    create(:user)
  end

  let(:automation_adapter) { create(:automation_adapter,
    user: user,
    project: project
  ) }

  let(:test_run) {
    test_run = execution.test_run
    test_run.executor = user
    test_run.status = 2
    test_run.save(validate: false)
    test_run
  }
  let(:version) { execution.version }
  let(:test_case) { version.test_case }
  let(:execution) { create(:execution, progress: 19) }
  let(:execution_progress_23) { create(:execution, progress: 23, test_run: test_run) }
  let(:execution_for_passed) do
    create(:execution_for_passed, test_run: test_run)
  end

  let(:execution_progress_29) do
    version =  create(:test_case_version, test_case: create(:test_case, name: 'Other Test Case'))
    create(:execution, progress: 29, test_run: test_run, version: version)
  end

  let(:foreign_execution) { create(:execution) }

  let(:project) { test_run.project}

  def query(syntax)
    Oslc::Automation::Request::Query.new(provider: project).where(syntax)
  end

  before do
    ready(execution, execution_progress_23, execution_progress_29, execution_for_passed, project, foreign_execution)
    Tmt::Execution.all.should match_array [
      execution,
      execution_progress_23,
      execution_progress_29,
      execution_for_passed,
      foreign_execution
    ]
  end

  it "should return executions when query syntax is empty" do
    result = query(nil)
    result.should match_array [
      execution,
      execution_progress_23,
      execution_progress_29,
      execution_for_passed
    ]
  end

  it "should return executions with progress equals 19" do
    result = query('rqm_auto:progress="19"')
    result.should match_array [execution]
  end

  it "should return executions with appropriate identifier" do
    identifier = server_url("/oslc/automation/service-providers/#{project.id}/requests/#{execution.id}")
    result = query("dcterms:identifier=\"#{identifier}\"")
    result.should match_array [execution]
  end

  it "should return executions for appropriate 'dcterms:title' property" do
    result = query("dcterms:title=\"Execute #{test_case.name}\"")
    result.should match_array [
      execution,
      execution_progress_23,
      execution_for_passed
    ]
  end

  it "should return executions for appropriate 'oslc_auto:state' property" do
    result = query("oslc_auto:state=<http://open-services.net/ns/auto#complete>")
    result.should match_array [execution_for_passed]
  end

  it "should return executions for appropriate 'dcterms:creator' property" do
    user_url = server_url("/oslc/users/#{test_run.creator_id}")
    result = query("dcterms:creator=<#{user_url}>")
    result.should match_array [
      execution,
      execution_progress_23,
      execution_progress_29,
      execution_for_passed
    ]
  end

  it "should return executions for appropriate 'rqm_auto:taken' property" do
    result = query("rqm_auto:taken=true")
    result.should match_array [execution_for_passed]
    result = query("rqm_auto:taken=false")
    result.should match_array [
      execution,
      execution_progress_23,
      execution_progress_29
    ]
  end

  it "should return executions for appropriate 'rqm_auto:executesOnAdapter' property" do
    adapter_url = server_url("/oslc/automation/service-providers/#{project.id}/adapters/#{automation_adapter.id}")
    result = query("rqm_auto:executesOnAdapter=<#{adapter_url}>")
    result.should match_array [
      execution,
      execution_progress_23,
      execution_progress_29,
      execution_for_passed
    ]
  end

  it "should return executions for appropriate 'oslc_auto:executesAutomationPlan' property" do
    plan_url = server_url("/oslc/automation/service-providers/#{project.id}/plans/#{execution_for_passed.id}")
    result = query("oslc_auto:executesAutomationPlan=<#{plan_url}>")
    result.should match_array [execution_for_passed]
  end

  it "should return executions for appropriate 'oslc_qm:executesTestScript' property" do
    test_script_id = execution_progress_23.version_id
    test_script_url = server_url("/oslc/qm/service-providers/#{project.id}/test-scripts/#{test_script_id}")
    result = query("oslc_qm:executesTestScript=<#{test_script_url}>")
    result.should match_array [execution_progress_23]
  end

  it "should return executions for appropriate 'dcterms:created' property" do
    time = Support::Oslc::Date.new(execution_progress_23.created_at).iso8601
    result = query("dcterms:created=\"#{time}\"")
    result.should match_array [execution_progress_23]
  end

  it "should return executions for appropriate 'dcterms:modified' property" do
    time = Support::Oslc::Date.new(execution.updated_at).iso8601
    result = query("dcterms:modified=\"#{time}\"")
    result.should match_array [execution]
  end

  it "should return Automation Requests when Test Run has set future date for due_data attribute" do
    query("").should match_array [
      execution,
      execution_progress_23,
      execution_progress_29,
      execution_for_passed
    ]
    test_run = execution.test_run
    test_run.due_date = Time.now + 1.day
    test_run.save(validate: false)
    query("").should be_empty
  end

end
