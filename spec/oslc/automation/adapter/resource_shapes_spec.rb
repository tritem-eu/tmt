require 'spec_helper'

describe Oslc::Automation::Adapter::ResourceShape do
  include Support::Oslc

  it_should_behave_like "set of OSLC resource shapes" do
    let(:resource_shape_url) do
      server_url('/oslc/automation/resource-shapes/adapter')
    end

    let(:resource_shape) do
      ::Oslc::Automation::Adapter::ResourceShape.new()
    end
  end
end
