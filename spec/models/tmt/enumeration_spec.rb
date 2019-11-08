require 'spec_helper'

describe Tmt::Enumeration do
  let(:enumeration) { create(:enumeration) }

  before do
    Tmt::Cfg.first.update(max_name_length: 35)
  end

  describe 'name attribute' do
    it "should not create record when length of name is greater than 35" do
      expect do
        create(:enumeration, name: 'a'*36)
      end.to raise_error(ActiveRecord::RecordInvalid, /does not have length between 1 and 35/)
    end

    it "should create record when length of name is lower than 36" do
      expect do
        create(:enumeration, name: 'a'*35)
      end.to change(Tmt::Enumeration, :count).by(1)
    end

    it "should valid name when it is not blank" do
      expect do
        create(:enumeration, name: 'Example name')
      end.to change(Tmt::Enumeration, :count).by(1)
    end

    it "should not valid name when it is blank" do
      expect do
        create(:enumeration, name: '')
      end.to raise_error(ActiveRecord::RecordInvalid, /Name can't be blank/)
    end
  end

  describe "#first_free_int_value" do
    let(:enumeration_value) {create(:enumeration_value, numerical_value: 0)}

    it "should return 1 when enumeration has got one value" do
      enumeration.values.delete
      create(:enumeration_value, numerical_value: 0, enumeration: enumeration)
      enumeration.first_free_int_value.should eq 1
    end

    it "should return 0 when enumeration hasn't got values" do
      enumeration.values.delete
      enumeration.first_free_int_value.should eq 0
    end
  end

  describe "#unassigned?" do
    it "should return true when a test run and a test case objects aren't assigned to enumeration" do
      enumeration = create(:enumeration_unassigned)
      enumeration.unassigned?.should be true
      enumeration.test_run_custom_field.should be nil
      enumeration.test_case_custom_field.should be nil
    end

    it "should return false when a test run objects is assigned to enumeration" do
      enumeration = create(:enumeration_for_test_run)
      enumeration.unassigned?.should be false
      enumeration.test_run_custom_field.should_not be nil
    end

    it "should return false when a test case objects is assigned to enumeration" do
      enumeration = create(:enumeration_for_test_case)
      enumeration.unassigned?.should be false
      enumeration.test_case_custom_field.should_not be nil
    end
  end

  describe ".unassigned" do
    it "should return 1 enumeartion which aren't assigned to test run and test case" do
      Tmt::Enumeration.delete_all
      enumeration = create(:enumeration_unassigned)
      create(:enumeration_for_test_case)
      create(:enumeration_for_test_run)
      Tmt::Enumeration.unassigned.should match_array([enumeration])
    end
  end

  describe "#related_custom_field" do
    it "should return true when a test run and a test case objects aren't assigned to enumeration" do
      enumeration = create(:enumeration_unassigned)
      enumeration.unassigned?.should be true
      enumeration.test_run_custom_field.should be_nil
      enumeration.test_case_custom_field.should be_nil
    end

    it "should return false when a test run objects is assigned to enumeration" do
      enumeration = create(:enumeration_for_test_run)
      enumeration.unassigned?.should be false
      enumeration.test_run_custom_field.should_not be_nil
    end

    it "should return false when a test case objects is assigned to enumeration" do
      enumeration = create(:enumeration_for_test_case)
      enumeration.unassigned?.should be false
      enumeration.test_case_custom_field.should_not be_nil
    end
  end

end
