require 'spec_helper'

describe Oslc::Qm::TestCase::Resources do
  it_should_behave_like "Resources class of OSLC" do
    def identifier_for(resource)
      project = resource.project
      server_url("/oslc/qm/service-providers/#{project.id}/test-cases/#{resource.id}")
    end

    let(:testing_class) { ::Oslc::Qm::TestCase::Resources }
    let(:project) { create(:project) }

    let(:first_resource) { create(:test_case, project: project, name: 'First')}
    let(:second_resource) { create(:test_case, project: project, name: 'Second')}
    let(:foreign_resource) { create(:test_case, name: 'Foreign')}
  end
end
