require 'spec_helper'

describe Tmt::Member do

  it "should properly valid record" do
    build(:machine).should be_valid
  end

  context "for MAC address validation" do
    it "should be valid when value is empty" do
      build(:machine, mac_address: nil).should be_valid
    end

    it "should raise error when value consists of incorrect string" do
      expect do
        create(:machine, mac_address: 'incorrect')
      end.to raise_error(ActiveRecord::RecordInvalid, /consists of six groups of two hexadecimal digits, separated by hyphens \(-\) or colons \(:\)/)
    end

    it "should be valid when value is correct" do
      build(:machine, mac_address: 'aa:bb:cc:dd:ee:ff').should be_valid
    end
  end

  context "for IP address validation" do
    it "should be valid when value is empty" do
      build(:machine, ip_address: nil).should be_valid
    end

    it "should raise error when value consists of incorrect string" do
      expect do
        create(:machine, ip_address: 'incorrect')
      end.to raise_error(ActiveRecord::RecordInvalid, /Ip address is invalid/)
    end

    it "should be valid when value is correct" do
      build(:machine, ip_address: '127.0.0.0').should be_valid
    end
  end

end
