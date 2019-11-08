require 'spec_helper'

describe Oslc::Automation::Request::Query do
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

  let(:automation_adapter) { create(:automation_adapter,
    user: user,
    project: project
  ) }

  let(:test_run) do
    test_run = execution.test_run
    test_run.executor_id =  test_run.creator_id
    test_run.save(validate: false)
    test_run
  end
  let(:version) { execution.version }
  let(:test_case) { version.test_case }
  let(:execution) { create(:execution, progress: 19) }
  let(:execution_progress_23) { create(:execution, progress: 23, test_run: test_run) }
  let(:execution_for_passed) do
    create(:execution_for_passed, test_run: test_run)
  end

  let(:execution_for_failed) do
    version = create(:test_case_version, test_case: create(:test_case, name: 'Other Test Case'))
    create(:execution_for_failed, test_run: test_run, version: version, comment: 'Result for failed execution')
  end

  let(:foreign_execution) { create(:execution) }

  let(:project) { test_run.project}

  def query(syntax)
    Oslc::Automation::Result::Query.new(provider: project).where(syntax)
  end

  before do
    ready(execution, execution_progress_23, execution_for_failed, execution_for_passed, project, foreign_execution)
    Tmt::Execution.all.should match_array [
      execution,
      execution_progress_23,
      execution_for_failed,
      execution_for_passed,
      foreign_execution
    ]
  end

  it "should return executions when query syntax is empty" do
    result = query(nil)
    result.should match_array [
      execution,
      execution_progress_23,
      execution_for_failed,
      execution_for_passed
    ]
  end

  it "should return executions with appropriate identifier" do
    identifier = server_url("/oslc/automation/service-providers/#{project.id}/results/#{execution_for_passed.id}")
    result = query("dcterms:identifier=\"#{identifier}\"")
    result.should match_array [execution_for_passed]
  end

  it "should return executions for appropriate 'dcterms:title' property" do
    result = query("dcterms:title=\"#{execution_for_failed.comment}\"")
    result.should match_array [
      execution_for_failed
    ]
  end

  it "should return executions for appropriate 'oslc_auto:state' property" do
    result = query("oslc_auto:state=<http://open-services.net/ns/auto#complete>")
    result.should match_array [execution_for_passed, execution_for_failed]
  end

  it "should return executions for appropriate 'oslc_auto:verdict' property" do
    result = query("oslc_auto:verdict=<http://open-services.net/ns/auto#failed>")
    result.should match_array [execution_for_failed]
  end

  it "should return executions for appropriate 'rqm_auto:executedOnMachine' property" do
    user_url = server_url("/oslc/users/#{test_run.creator_id}")
    result = query("rqm_auto:executedOnMachine=<#{user_url}>")
    result.should match_array [
      execution,
      execution_progress_23,
      execution_for_failed,
      execution_for_passed
    ]
  end

  it "should return executions for appropriate 'oslc:serviceProvider' property" do
    url = server_url("/oslc/automation/service-providers/#{project.id}")
    result = query("oslc:serviceProvider=\"#{url}\"")
    result.should match_array [
      execution,
      execution_for_passed,
      execution_progress_23,
      execution_for_failed
    ]
  end

  it "should return executions for appropriate 'oslc_auto:reportsOnAutomationPlan' property" do
    url = server_url("/oslc/automation/service-providers/#{project.id}/plans/#{execution.id}")
    result = query("oslc_auto:reportsOnAutomationPlan=<#{url}>")
    result.should match_array [execution]
  end

  it "should return executions for appropriate 'oslc_auto:producedByAutomationRequest' property" do
    url = server_url("/oslc/automation/service-providers/#{project.id}/requests/#{execution_for_passed.id}")
    result = query("oslc_auto:producedByAutomationRequest=<#{url}>")
    result.should match_array [execution_for_passed]
  end

  it "should return executions for appropriate 'oslc_qm:reportsOnTestCase' property" do
    url = server_url("/oslc/qm/service-providers/#{project.id}/test-cases/#{test_case.id}")
    result = query("oslc_qm:reportsOnTestCase=<#{url}>")
    result.should match_array [execution]
  end

  it "should return executions for appropriate 'oslc:instanceShape' property" do
    url = server_url('/oslc/automation/resource-shapes/result')
    result = query("oslc:instanceShape=<#{url}>")
    result.should match_array [
      execution,
      execution_for_failed,
      execution_for_passed,
      execution_progress_23
    ]
    result = query("oslc:instanceShape=\"\"")
    result.should match_array []
  end

  it "should return executions for appropriate 'dcterms:created' property" do
    time = Support::Oslc::Date.new(execution_for_failed.created_at).iso8601
    result = query("dcterms:created=\"#{time}\"")
    result.should match_array [execution_for_failed]
  end

  it "should return executions for appropriate 'dcterms:modified' property" do
    time = Support::Oslc::Date.new(execution_for_passed.updated_at).iso8601
    result = query("dcterms:modified=\"#{time}\"")
    result.should match_array [execution_for_passed]
  end

  it "should return executions for appropriate 'oslc_auto:producedByAutomationRequest' property (scope version)" do
    execution_for_passed.test_case.update(name: 'Closing window')
    result = query("oslc_auto:producedByAutomationRequest{dcterms:title=\"Execute Closing window\"}")
    result.should match_array [execution_for_passed]
  end

  it "should return executions for appropriate 'oslc_qm:reportsOnTestCase' property (scope version)" do
    execution_for_failed.test_case.update(name: 'Closing window', project: project)
    result = query("oslc_qm:reportsOnTestCase{dcterms:title=\"Closing window\"}")
    result.should match_array [execution_for_failed]
  end

  it "should return executions for appropriate 'oslc_qm:reportsOnTestCase' property (scope version)" do
    test_case = execution_for_failed.test_case
    version = test_case.versions[0]
    test_script_url = server_url("/oslc/qm/service-providers/#{project.id}/test-scripts/#{version.id}")
    result = query("oslc_qm:reportsOnTestCase{oslc_qm:usesTestScript{dcterms:identifier=\"#{test_script_url}\"}}")
    result.should match_array [execution_for_failed]
  end

  it "should return executions for appropriate 'oslc_qm:reportsOnTestCase' property when Test Case resource was created be 'Peter'" do
    test_case = execution_for_failed.test_case
    peter = create(:user, name: 'Peter')
    test_case.update(creator: peter)
    result = query("oslc_qm:reportsOnTestCase{dcterms:creator{foaf:name=\"#{peter.name}\"}}")
    result.should match_array [execution_for_failed]
  end

end
