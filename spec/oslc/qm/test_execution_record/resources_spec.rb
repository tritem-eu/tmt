require 'spec_helper'

describe Oslc::Qm::TestExecutionRecord::Resources do
  it_should_behave_like "Resources class of OSLC" do
    def identifier_for(resource)
      project = resource.project
      server_url("/oslc/qm/service-providers/#{project.id}/test-execution-records/#{resource.id}")
    end

    let(:testing_class) { ::Oslc::Qm::TestExecutionRecord::Resources }
    let(:project) { test_run.project }
    let(:test_run) { create(:test_run) }

    let(:first_resource) { create(:execution, test_run: test_run)}
    let(:second_resource) { create(:execution, test_run: test_run)}
    let(:foreign_resource) { create(:execution)}
  end
end
