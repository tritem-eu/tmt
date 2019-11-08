require 'spec_helper'

describe Oslc::Qm::TestResult::Resources do
  it_should_behave_like "Resources class of OSLC" do
    def identifier_for(resource)
      project = resource.project
      server_url("/oslc/qm/service-providers/#{project.id}/test-results/#{resource.id}")
    end

    let(:testing_class) { ::Oslc::Qm::TestResult::Resources }
    let(:project) { first_resource.project }
    let(:test_run) { first_resource.test_run }
    let(:first_resource) { create(:execution) }
    let(:second_resource) { create(:execution, status: 'passed', comment: 'Report of execution', test_run: create(:test_run, campaign: test_run.campaign)) }
    let(:foreign_resource) { create(:execution) }
  end

end
