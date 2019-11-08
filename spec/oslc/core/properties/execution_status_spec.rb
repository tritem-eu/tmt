require 'spec_helper'

describe Oslc::Core::Properties::ExecutionStatus do

  let(:klass) {Oslc::Core::Properties::ExecutionStatus}

  [
    ['none', "http://open-services.net/ns/auto#new"],
    ['executing', "http://open-services.net/ns/auto#inProgress"],
    ['error', "http://open-services.net/ns/auto#complete"],
    ['passed', "http://open-services.net/ns/auto#complete"],
    ['failed', "http://open-services.net/ns/auto#complete"]
  ].each do |status, state|
    it "should map '#{status}' execution status to '#{state}' OSLC state" do
      klass.new(status).map_to_state_property.should eq(state)
    end
  end

  [
    ['none', nil],
    ['executing', nil],
    ['error', "http://open-services.net/ns/auto#error"],
    ['passed', "http://open-services.net/ns/auto#passed"],
    ['failed', "http://open-services.net/ns/auto#failed"]
  ].each do |status, state|
    it "should map '#{status}' execution status to '#{state}' OSLC verdict" do
      klass.new(status).map_to_verdict_property.should eq(state)
    end
  end

end
