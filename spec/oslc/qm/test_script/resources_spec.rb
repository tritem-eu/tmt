require 'spec_helper'

describe Oslc::Qm::TestScript::Resources do
  it_should_behave_like "Resources class of OSLC" do
    def identifier_for(resource)
      project = resource.project
      server_url("/oslc/qm/service-providers/#{project.id}/test-scripts/#{resource.id}")
    end

    let(:oliver) { create(:user, name: 'Oliver') }

    let(:testing_class) { ::Oslc::Qm::TestScript::Resources }

    let(:project) do
      project = create(:project)
      project.add_member(oliver)
      project
    end

    let(:first_resource) do
      create(:test_case_version,
        test_case: create(:test_case, project: project),
        author: oliver,
        comment: 'Open window.'
      )
    end

    let(:second_resource) do
      create(:test_case_version,
        test_case: create(:test_case, project: project),
        author: oliver,
        comment: 'Turn on light.'
      )
    end

    let(:foreign_resource) do
      create(:test_case_version,
        test_case: create(:test_case),
        author: oliver,
        comment: 'Close door.'
      )
    end
  end
end
