require 'spec_helper'

describe Oslc::Automation::Request::Resources do
  it_should_behave_like "Resources class of OSLC" do
    def identifier_for(resource)
      project = resource.project
      server_url("/oslc/automation/service-providers/#{project.id}/requests/#{resource.id}")
    end

    let(:testing_class) { ::Oslc::Automation::Request::Resources }

    let(:project) { test_run.project}

    let(:machine) do
      user = create(:user)
      project.add_member(user)
      user
    end

    let(:test_run) do
      test_run = first_resource.test_run
      test_run.status = 2
      test_run.save(validate: false)
      test_run
    end
    let(:first_resource) { create(:execution) }
    let(:second_resource) do
      new_test_run = create(:test_run, campaign: test_run.campaign)
      new_test_run.status = 2
      new_test_run.save(validate: false)
      create(:execution, status: 'passed', comment: 'Report of execution', test_run: new_test_run)
    end
    let(:foreign_resource) { create(:execution) }
  end
end
