require 'spec_helper'

describe Oslc::Automation::PlansController do
  include Support::Oslc::Controllers::Resource
  extend CanCanHelper

  let(:admin) { create(:admin) }

  let(:execution) { create(:execution) }

  let(:test_run) { execution.test_run }
  let(:project) { test_run.project}
  let(:user) do
    user = create(:user)
    project.add_member(user)
    user
  end

  let(:xml) { Nokogiri::XML(response.body)}

  before do
    ready(project, user)
  end

  it_should_behave_like "GET 'show' for OSLC resource" do
    let(:type) {"oslc_auto:AutomationPlan"}
    let(:user_to_log) { user }
    let(:resource) { execution }
  end

  it_should_behave_like "GET query for OSLC resources" do
    let(:type) {"oslc_auto:AutomationPlan"}
    let(:user_to_log) { user }
    let(:resources_from_project) do
      [
        execution,
        create(:execution, test_run: test_run)
      ]
    end
    let(:foreign_resource) do
      create :execution
    end
    let(:dcterms_identifier) do
      server_url "/oslc/automation/service-providers/#{project.id}/plans/#{execution.id}"
    end
  end

end
