require 'spec_helper'

describe Tmt::TestCaseType do
  before do
    Tmt::Cfg.first.update(max_name_length: 35)
  end

  it "should create record" do
    expect do
      create(:test_case_type)
    end.to change(Tmt::TestCaseType, :count).by(1)
  end

  describe ".validates" do
    it "should not create record when length of name is greater than 35" do
      expect do
        create(:test_case_type, name: 'a'*36)
      end.to raise_error(ActiveRecord::RecordInvalid, /does not have length between 1 and 35/)
    end

    it "should create record when length of name is lower than 36" do
      expect do
        create(:test_case_type, name: 'a'*35)
      end.to change(Tmt::TestCaseType, :count).by(1)
    end
  end

  describe '#is_unused? method' do
    it "isn't used" do
      create(:test_case_type, test_cases: []).is_unused?.should be true
    end

    it "is used" do
      type = create(:test_case_type)
      create(:test_case, type: type)
      type.is_unused?.should be false
    end
  end

  describe "for name attribute" do
    it "should not valid empty name" do
      build(:test_case_type, name: nil).should_not be_valid
    end

    it "should valid not empty name" do
      build(:test_case_type, name: 'Example').should be_valid
    end

    it "should not duplicate name" do
      create(:test_case_type, name: 'Example')
      build(:test_case_type, name: 'Example').should_not be_valid
    end
  end

  describe "for converter attribute" do
    it "should set 'none' converter" do
      build(:test_case_type, converter: nil).should be_valid
    end

    it "should set 'sequence' converter" do
      build(:test_case_type, converter: 'sequence').should be_valid
    end

    it "should not set 'undefined' converter" do
      build(:test_case_type, converter: 'undefined').should_not be_valid
    end
  end

  describe ".undeleted" do
    it "return records which are not deleted" do
      Tmt::TestCaseType.delete_all
      type_one = create(:test_case_type, deleted_at: Time.now)
      type_undeleted = create(:test_case_type, deleted_at: nil)
      type_three = create(:test_case_type, deleted_at: Time.now)
      Tmt::TestCaseType.undeleted.should_not match_array([type_one, type_three])
      Tmt::TestCaseType.undeleted.should match_array([type_undeleted])
    end
  end

  describe "#set_deleted" do
    it "should set 'deleted_at' attribute on true when it isn't used" do
      type = create(:test_case_type)
      type.set_deleted
      type.reload.deleted_at.should_not be_nil
    end

    it "should not set 'deleted_at' attribute on true when it is used" do
      type = create(:test_case).type
      type.set_deleted
      type.reload.deleted_at.should be_nil
    end
  end
end
