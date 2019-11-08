require 'spec_helper'

describe Oslc::Qm::TestPlan::Resources do
  it_should_behave_like "Resources class of OSLC" do
    def identifier_for(resource)
      project = resource.project
      server_url("/oslc/qm/service-providers/#{project.id}/test-plans/#{resource.id}")
    end

    let(:testing_class) { ::Oslc::Qm::TestPlan::Resources }
    let(:project) { first_resource.project }
    let(:campaign) { first_resource.campaign }

    let(:first_resource) { create(:test_run)}
    let(:second_resource) { create(:test_run, campaign: campaign) }
    let(:foreign_resource) { create(:test_run)}
  end

end
