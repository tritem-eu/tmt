require 'spec_helper'

describe Oslc::Automation::Adapter::Query do
  include Support::Oslc

  let(:project) do
    project = create(:project)
    project.add_member(user)
    project
  end

  let(:ax_machine) do
    Tmt::Machine.create(user: ax_user,
      ip_address: '127.0.0.1',
      hostname: 'ax',
      fully_qualified_domain_name: 'ax.example.com',
      mac_address: 'ff:ff:ff:ff:ff:ff'
    )
  end

  let(:tmt_machine) do
    Tmt::Machine.create(user: tmt_user,
      ip_address: '127.0.0.2',
      hostname: 'tmt',
      fully_qualified_domain_name: 'tmt.example.com',
      mac_address: 'ee:ee:ee:ee:ee:ee'
    )
  end

  let(:ax_user) do
    user = create(:user)
    project.add_member(user)
    user
  end

  let(:tmt_user) do
    user = create(:user)
    project.add_member(user)
    user
  end

  let(:ax_adapter) { create(:automation_adapter,
    user: ax_user,
    project: project,
    name: 'AX Adapter',
    polling_interval: 2
  ) }

  let(:tmt_adapter) { create(:automation_adapter,
    user: tmt_user,
    project: project,
    name: 'TMT Adapter',
    polling_interval: 3
  ) }

  let(:foreign_adapter) { create(:automation_adapter, name: 'Foreign Adapter') }

  let(:test_run) { execution.test_run }
  let(:execution) { create(:execution, progress: 19) }
  let(:execution_for_passed) do
    create(:execution_for_passed, test_run: test_run)
  end

  let(:project) { test_run.project}

  def query(syntax)
    Oslc::Automation::Adapter::Query.new(provider: project).where(syntax)
  end

  before do
    ready(ax_adapter, tmt_adapter, foreign_adapter, tmt_machine, ax_machine)
    Tmt::AutomationAdapter.all.should match_array [
      ax_adapter,
      tmt_adapter,
      foreign_adapter
    ]
  end

  it "should return executions when query syntax is empty" do
    result = query(nil)
    result.should match_array [
      ax_adapter,
      tmt_adapter
    ]
  end

  it "should return adapters with appropriate identifier" do
    identifier = server_url("/oslc/automation/service-providers/#{project.id}/adapters/#{ax_adapter.id}")
    result = query("dcterms:identifier=\"#{identifier}\"")
    result.should match_array [ax_adapter]
  end

  it "should return adapters for appropriate 'dcterms:title' property" do
    result = query("dcterms:title=\"#{ax_adapter.name}\"")
    result.should match_array [ax_adapter]
  end

  it "should return adapters for appropriate 'rqm_auto:ipAddress' property" do
    result = query("rqm_auto:ipAddress=\"#{ax_machine.ip_address}\"")
    result.should match_array [ax_adapter]
  end

  it "should return adapters for appropriate 'dcterms:creator' property" do
    user_url = server_url("/oslc/users/#{ax_user.id}")
    result = query("dcterms:creator=<#{user_url}>")
    result.should match_array [
      ax_adapter
    ]
  end

  it "should return adapters for appropriate 'rqm_auto:workAvailable' property" do
    result = query("rqm_auto:workAvailable=false")
    result.should match_array [tmt_adapter, ax_adapter]
  end

  it "should return adapters for appropriate 'dcterms:type' property" do
    result = query("dcterms:type=\"#{ax_adapter.adapter_type}\"")
    result.should match_array [ax_adapter, tmt_adapter]
  end

  it "should return adapters for appropriate 'rqm_auto:pollingInterval' property" do
    result = query("rqm_auto:pollingInterval=#{ax_adapter.polling_interval}")
    result.should match_array [ax_adapter]
  end

  it "should return adapters for appropriate 'dcterms:created' property" do
    time = Support::Oslc::Date.new(tmt_adapter.created_at).iso8601
    result = query("dcterms:created=\"#{time}\"")
    result.should match_array [tmt_adapter]
  end

  it "should return adapters for appropriate 'dcterms:modified' property" do
    time = Support::Oslc::Date.new(ax_adapter.updated_at).iso8601
    result = query("dcterms:modified=\"#{time}\"")
    result.should match_array [ax_adapter]
  end

  it "should return adapters for appropriate 'rqm_auto:fullyQualifiedDomainName' property" do
    result = query("rqm_auto:fullyQualifiedDomainName=\"tmt.example.com\"")
    result.should match_array [tmt_adapter]
  end

  it "should return adapters for appropriate 'rqm_auto:macAddress' property" do
    result = query("rqm_auto:macAddress=\"#{ax_adapter.mac_address}\"")
    result.should match_array [ax_adapter]
  end

  it "should return adapters for appropriate 'rqm_auto:hostname' property" do
    result = query("rqm_auto:hostname=\"#{ax_adapter.hostname}\"")
    result.should match_array [ax_adapter]
  end
end
