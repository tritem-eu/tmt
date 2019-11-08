require 'spec_helper'

describe Tmt::TestCasesSets do
  let(:project) { create(:project) }
  let(:set) { create(:set, project: project) }
  let(:test_case) { create(:test_case, project: project) }

  before do
    ready(set)
    ready(test_case)
  end

  it "should validate new record" do
    expect do
      Tmt::TestCasesSets.create!(set: set, test_case: test_case)
    end.to_not raise_error
  end

  it "shouldn't validate new record when set is nil" do
    Tmt::TestCasesSets.new(set: nil, test_case: test_case).should_not be_valid
  end

  it "shouldn't validate new record when test_case is nil" do
    Tmt::TestCasesSets.new(set: set, test_case: nil).should_not be_valid
  end

  it "shouldn't validate new record when objects set and test_case belong into another proejcts" do
    Tmt::TestCasesSets.new(set: create(:set), test_case: create(:test_case)).should_not be_valid
  end

  it "shouldn't duplicate data in model" do
    record = Tmt::TestCasesSets.new(set: set, test_case: test_case)
    record.should be_valid
    record.save
    record = Tmt::TestCasesSets.new(set:set, test_case: test_case)
    record.should_not be_valid
  end
end
