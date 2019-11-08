require 'spec_helper'

describe ::Tmt::Tasks::Seed, type: :lib do
  describe "Uploading default Custom Fields variables for Sandbox" do
    before do
      create(:admin)
    end
=begin
    it "should create 4 custom fields for TestRun class" do
      ::Tmt::Tasks::Seed.sandbox
      ::Tmt::TestRunCustomField.all.map(&:name).should match_array(["DefaultNetwork", "EnsureLocoNumber", "RebootHardware", "isOfficial"])
    end

    it "should not duplicate custom field entries" do
      ::Tmt::Tasks::Seed.sandbox
      ::Tmt::Tasks::Seed.sandbox
      ::Tmt::TestRunCustomField.all.map(&:name).should match_array(["DefaultNetwork", "EnsureLocoNumber", "RebootHardware", "isOfficial"])
    end

    it "should create enumeration entries" do
      ::Tmt::Tasks::Seed.sandbox
      ::Tmt::Enumeration.all.map(&:name).should match_array(["EnsureLocoNumber", "DefaultNetwork"])
    end

    it "should not duplicate enumeration entry" do
      ::Tmt::Tasks::Seed.sandbox
      ::Tmt::Tasks::Seed.sandbox
      ::Tmt::Enumeration.all.map(&:name).should match_array(["EnsureLocoNumber", "DefaultNetwork"])
    end

    it "should create enumeration value entries" do
      ::Tmt::Tasks::Seed.sandbox
      ::Tmt::Tasks::Seed.sandbox
      records = ::Tmt::EnumerationValue.where(text_value: 'CFL_25kV')
      records.should have(1).item
      records.first.numerical_value.should eq(2)
    end
=end
  end
end
