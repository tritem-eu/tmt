require 'spec_helper'

describe Oslc::Qm::TestCase::ResourceShape do
  include Support::Oslc

  it_should_behave_like "set of OSLC resource shapes" do
    let(:resource_shape_url) {
      server_url('/oslc/qm/resource-shapes/test-case')
    }

    let(:resource_shape) do
      ::Oslc::Qm::TestCase::ResourceShape.new()
    end
  end
end
