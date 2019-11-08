require 'spec_helper'

describe Oslc::Qm::TestExecutionRecord::ResourceShape do
  include Support::Oslc

  it_should_behave_like "set of OSLC resource shapes" do
    let(:resource_shape_url) {
      server_url('/oslc/qm/resource-shapes/test-execution-record')
    }

    let(:resource_shape) do
      ::Oslc::Qm::TestExecutionRecord::ResourceShape.new()
    end
  end

end
