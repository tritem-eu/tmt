require 'spec_helper'

describe Tmt::OslcCfg do

  let(:cfg) { Tmt::OslcCfg.cfg }

  let(:test_case_type) { create(:test_case_type) }

  it "should not allow deletion of the configuration record" do
    ready(cfg)
    expect do
      cfg.destroy
    end.to_not change(Tmt::OslcCfg, :count)
  end

  it "should have only one entry" do
    cfg.should be_a(Tmt::OslcCfg)
    Tmt::OslcCfg.create(test_case_type: test_case_type).should_not be_valid
    Tmt::OslcCfg.should have(1).item
  end

end
