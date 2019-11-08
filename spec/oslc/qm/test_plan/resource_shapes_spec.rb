require 'spec_helper'

describe Oslc::Qm::TestPlan::ResourceShape do
  include Support::Oslc

  it_should_behave_like "set of OSLC resource shapes" do
    let(:resource_shape_url) {
      server_url('/oslc/qm/resource-shapes/test-plan')
    }

    let(:resource_shape) do
      ::Oslc::Qm::TestPlan::ResourceShape.new()
    end
  end
end
