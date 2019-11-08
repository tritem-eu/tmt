require 'spec_helper'

describe Tmt::Campaign do
  let(:project) { create(:project) }

  let(:beta_project) { create(:project) }
  let(:campaign) { create(:campaign, project: project, name: "Name") }
  let(:time_now) { Time.now }

  describe '.validates' do
    it "should be valid" do
      build(:campaign).should be_valid
    end

    it "shouldn't create when project is nil" do
      build(:campaign, project: nil).should_not be_valid
    end

    it "shouldn't create when name is blank" do
      build(:campaign, name: '').should_not be_valid
    end

    it "shouldn't create when deadline is incorrect" do
      campaign = build(:campaign, name: 'Example name', deadline_at: '2016-10-10 99:99:99')
      campaign.should_not be_valid
      campaign.errors[:deadline_at].should eq(["invalid deadline"])
    end

    it "should create when deadline is correct" do
      campaign = build(:campaign, name: 'Example name', deadline_at: '2016-10-10 10:10:10')
      campaign.should be_valid
      campaign.deadline_at.in_time_zone.should eq('2016-10-10 10:10:10 UTC')
    end

    it "should create when name is properly" do
      build(:campaign, name: 'Example name').should be_valid
    end
  end

  it "#close can close campaign" do
    campaign.is_open.should be true
    time_now
    Time.stub(:now).and_return(time_now)
    campaign.close
    campaign.is_open.should be false
    campaign.deadline_at.should eq(time_now)
  end

  describe "for attribute is_open" do
    it "when project hasn't got campaigns then we can create new campaign" do
      expect do
        create(:campaign, project: project)
      end.to change{Tmt::Campaign.count}.from(0).to(1)
    end

    it "when project hasn't got open campaign then we can create new campaign" do
      campaign.close.should be true
      expect do
        create(:campaign, project: project)
      end.to change{Tmt::Campaign.count}.from(1).to(2)
    end

    it "when project has got open campaign then we can create new campaign" do
      create(:campaign, project: project)
      expect do
        create(:campaign, project: project)
      end.to raise_error
    end
  end

  it "a maximum of only one campaign can be opened per project" do
    create(:campaign, project: project, name: "Unique name").close
    build(:campaign, project: project, name: "Unique name").should_not be_valid
    build(:campaign, project: beta_project, name: "Unique name").should be_valid
  end

  it "User cannot update closed campaign" do
    campaign.update(name: "Old name")
    campaign.name.should eq("Old name")
    campaign.close

    expect do
      campaign.update!(name: "Old name 2")
    end.to raise_error
  end
end
