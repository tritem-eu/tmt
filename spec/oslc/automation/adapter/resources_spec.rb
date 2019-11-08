require 'spec_helper'

describe Oslc::Automation::Adapter::Resources do
  it_should_behave_like "Resources class of OSLC" do
    def identifier_for(resource)
      project = resource.project
      server_url("/oslc/automation/service-providers/#{project.id}/adapters/#{resource.id}")
    end

    let(:testing_class) { ::Oslc::Automation::Adapter::Resources }
    let(:project) do
      project = create(:project)
      project.add_member(john)
      project.add_member(oliver)
      project
    end

    let(:additional_options) { {current_user: john} }

    let(:john) do
      create(:user)
    end

    let(:oliver) do
      create(:user)
    end

    let(:first_resource) { create(:automation_adapter, name: 'Title 05.11.2014 11:20', project: project, polling_interval: 29, user: john) }
    let(:second_resource) { create(:automation_adapter, name: 'Title 26.08.2015 11:20', project: project, polling_interval: 29, user: oliver) }
    let(:foreign_resource) { create(:automation_adapter, name: 'Title 05.11.2014 13:20') }
  end
end
