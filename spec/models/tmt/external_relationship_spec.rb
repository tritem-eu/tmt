require 'spec_helper'

describe Tmt::ExternalRelationship do
  let(:project) { create(:project) }

  let(:user) { create(:user) }

  let(:test_case) { create(:test_case, project: project, creator: user) }
  let(:test_case_second) { create(:test_case, project: project, creator: user) }

  let(:external_relationship) { create(:external_relationship)}

  it "shoud create new exteranal relationship" do
    expect do
      create(:external_relationship, url: 'http://www.example.com')
    end.to change(Tmt::ExternalRelationship, :count).by(1)
  end

  it "should get source of external relationship" do
    create(:external_relationship, source: test_case).source.should eq(test_case)
  end

  it "is invalid when attributes: value, url and rq_id are blank" do
    expect do
      create(:external_relationship, value: "", url: nil, rq_id: "")
    end.to raise_error(ActiveRecord::RecordInvalid, /Cannot create a relationship with no data in it. Fill at least one field/)
  end

  it "is invalid when url does not match to pattern http(s)://.*" do
    expect do
      create(:external_relationship, value: nil, url: 'www.example.com', kind: 'url')
    end.to raise_error(ActiveRecord::RecordInvalid, /doesn't match the pattern http/)
  end

  it "valid when url matches to pattern http(s)://.*" do
    build(:external_relationship, value: nil, url: 'https://www.example.com', kind: 'url').should be_valid
    build(:external_relationship, value: nil, url: 'http://www.example.com', kind: 'url').should be_valid
  end

  it "is invalid when source is empty" do
    build(:external_relationship, source: nil).should_not be_valid
  end

  it "should invalid entry when rq_id attribute doesn't exist in ids of Test Cases" do
    entry = build(:external_relationship, rq_id: 0, kind: 'rq_id')
    entry.should_not be_valid
    entry.errors[:rq_id].should eq ["doesn't exist"]
  end

  it "should valid entry when rq_id attribute exists in ids of Test Cases" do
    ready(test_case, test_case_second)
    build(:external_relationship, rq_id: test_case_second.id, kind: 'rq_id').should be_valid
  end

  it "should erase rq_id when kind is set on 'url'" do
    entry = create(:external_relationship,
      rq_id: test_case.id,
      url: 'http://example.com',
      value: 'Example',
      kind: 'url'
    )
    entry.reload.rq_id.should be_nil
    entry.url.should eq 'http://example.com'
    entry.value.should eq 'Example'
  end

  it "should erase url and value when kind is set on 'rq_id'" do
    entry = create(:external_relationship,
      rq_id: test_case.id,
      value: 'Example',
      url: 'http://example.com',
      kind: 'rq_id'
    )
    entry.reload.rq_id.should eq test_case.id
    entry.url.should be_nil
    entry.value.should be_nil
  end
end
