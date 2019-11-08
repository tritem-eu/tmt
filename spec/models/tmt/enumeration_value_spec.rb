require 'spec_helper'

describe Tmt::EnumerationValue do
  let(:priority) { create(:enumeration_for_priorities, test_run_custom_field_id: nil, test_case_custom_field_id: nil) }

  before do
    Tmt::Cfg.first.update(max_name_length: 35)
  end

  it "should make sure that the numerical value exists" do
    expect do
      env = Tmt::EnumerationValue.new
      env.text_value = "text";
      env.save!
    end.to raise_error
  end

  it "should make sure that the text value exists" do
    expect do
      env = Tmt::EnumerationValue.new
      env.numerical_value = 2;
      env.save!
    end.to raise_error
  end

  describe "#before_destroy" do

    it "should not destroy entry when enumeration is used by custom field" do
      custom_field = create(:test_case_custom_field_for_enumeration, enumeration_id: priority.id)
      priority_value = custom_field.enumeration.values.first
      expect do
        priority_value.destroy
      end.to change(Tmt::EnumerationValue, :count).by(0)
      priority_value.errors[:base].should eq ["You cannot destroy it when some custom field using it"]
    end

    it "should destroy entry when enumeration is not used by custom field" do
      priority_value = priority.values.first
      expect do
        priority_value.destroy
      end.to change(Tmt::EnumerationValue, :count).by(-1)
    end

  end

  describe "validate text_value attribute" do
    it "should update text value when enumeration is used by some custom field" do
      custom_field = create(:test_case_custom_field_for_enumeration, enumeration_id: priority.id)
      priority_value = custom_field.enumeration.values.first
      priority_value.update(text_value: '2014.07.11 09:48')
      priority_value.reload.text_value.should eq('2014.07.11 09:48')
      priority_value.should be_valid
    end

    it "should update text value when enumeration is used by some custom field" do
      enumeration = create(:enumeration_for_priorities, test_case_custom_field_id: nil, test_run_custom_field_id: nil)
      priority_value = enumeration.values.first
      priority_value.update(text_value: '2014.07.11 09:48')
      priority_value.reload.text_value.should eq('2014.07.11 09:48')
      priority_value.should be_valid
    end

    it "should not create record when length of text_value is greater than 35" do
      expect do
        create(:enumeration_value, text_value: 'a'*36)
      end.to raise_error(ActiveRecord::RecordInvalid, /does not have length between 0 and 35/)
    end

    it "should create record when length of text_value is lower than 36" do
      expect do
        create(:enumeration_value, text_value: 'a'*35)
      end.to change(Tmt::EnumerationValue, :count).by(1)
    end
  end

  describe "validate numerical_value attribute" do
    it "should not update numerical value when enumeration is used by some custom field" do
      custom_field = create(:test_case_custom_field_for_enumeration, enumeration_id: priority.id)
      priority_value = custom_field.enumeration.values.first
      priority_value.update(numerical_value: 1000)
      priority_value.reload.numerical_value.should_not eq(1000)
      priority_value.errors[:numerical_value].should include("cannot be changed when enumeration is used by some custom field")
    end

    it "should update numerical value when enumeration is used by some custom field" do
      enumeration = create(:enumeration_for_priorities, test_case_custom_field_id: nil, test_run_custom_field_id: nil)
      priority_value = enumeration.values.first
      priority_value.update(numerical_value: 1000)
      priority_value.reload.numerical_value.should eq(1000)
      priority_value.should be_valid
    end

    it "should not update numerical value when exist other values with this same numerical value" do
      enumeration = create(:enumeration_for_priorities, test_case_custom_field_id: nil, test_run_custom_field_id: nil)
      first_value = enumeration.values[0]
      second_value = enumeration.values[1]
      first_value.update(numerical_value: second_value.numerical_value)
      first_value.errors[:numerical_value].should include("has already been taken")
    end

  end

end
