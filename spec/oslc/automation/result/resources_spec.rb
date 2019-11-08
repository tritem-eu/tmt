require 'spec_helper'

describe Oslc::Automation::Request::Resources do
  it_should_behave_like "Resources class of OSLC" do
    def identifier_for(resource)
      project = resource.project
      server_url("/oslc/automation/service-providers/#{project.id}/results/#{resource.id}")
    end

    let(:testing_class) { ::Oslc::Automation::Result::Resources }

    let(:project) { test_run.project}

    let(:machine) do
      user = create(:user)
      project.add_member(user)
      user
    end

    let(:test_run) { first_resource.test_run }
    let(:first_resource) { create(:execution) }
    let(:second_resource) { create(:execution, status: 'passed', comment: 'Report of execution', test_run: create(:test_run, campaign: test_run.campaign)) }
    let(:foreign_resource) { create(:execution) }
  end
end
