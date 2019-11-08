require 'spec_helper'

describe Oslc::Core::Properties::StateAndVerdict do

  let(:klass) {Oslc::Core::Properties::StateAndVerdict}

  [
    ["http://open-services.net/ns/auto#new", "http://open-services.net/ns/auto#error", nil],
    ["http://open-services.net/ns/auto#new", nil, 'none'],
    ["http://open-services.net/ns/auto#inProgress", nil, 'executing'],
    ["http://open-services.net/ns/auto#queued", nil, 'executing'],
    ["http://open-services.net/ns/auto#canceling", nil, 'error'],
    ["http://open-services.net/ns/auto#canceled", nil, 'error'],
    ["http://open-services.net/ns/auto#caneling", '', nil],
    ["http://open-services.net/ns/auto#complete", "http://open-services.net/ns/auto#error", 'error'],
    ["http://open-services.net/ns/auto#complete", nil, nil],
  ].each do |state, verdict, execution_status|
    it "should map '#{state}' OSLC state and '#{verdict}' OSLC verdict to '#{execution_status}' execution status" do
      klass.new(state, verdict).map_to_execution_status.should eq(execution_status)
    end
  end

end
