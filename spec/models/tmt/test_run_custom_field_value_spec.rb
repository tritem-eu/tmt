require 'spec_helper'

describe Tmt::TestRunCustomFieldValue do

  let(:test_run) { create(:test_run) }

  let(:project) { test_run.project }

  context "for type int" do
    let(:custom_field) { create(:test_run_custom_field_for_integer, lower_limit: -10, upper_limit: 100)}
    let(:valid_attributes) do
      {
        custom_field_id: custom_field.id,
        value: 37,
        test_run_id: test_run.id
      }
    end

    let(:custom_field_value) do
      Tmt::TestRunCustomFieldValue.create(valid_attributes)
    end

    it "should create without value" do
      expect do
        Tmt::TestRunCustomFieldValue.create(valid_attributes.merge(value: nil))
      end.to change(Tmt::TestRunCustomFieldValue, :count).by(1)
    end

    it "should update value to 43" do
      custom_field_value.update(value: 43)
      custom_field_value.value.should eq(43)
    end

    it "should not update value to -20" do
      expect do
        custom_field_value.update!(value: -20)
      end.to raise_error(ActiveRecord::RecordInvalid, /value is too low \(minimum is -10\)/)
      custom_field_value.reload.value.should_not eq(-20)
    end

    it "should not update value to 101" do
      expect do
        custom_field_value.update!(value: 101)
      end.to raise_error(ActiveRecord::RecordInvalid, /value is too high \(maximum is 100\)/)
      custom_field_value.reload.value.should_not eq(101)
    end

  end

  context "for type string" do
    let(:custom_field) { create(:test_run_custom_field, lower_limit: 5, upper_limit: 10, project_id: project.id)}

    let(:valid_attributes) do
      {
        custom_field_id: custom_field.id,
        value: 'test5',
        test_run_id: test_run.id
      }
    end

    let(:custom_field_value) do
      Tmt::TestRunCustomFieldValue.create(valid_attributes)
    end

    it "should create without value" do
      custom_field_value = Tmt::TestRunCustomFieldValue.create(valid_attributes.merge(value: nil))
      custom_field_value.reload.id.should_not be_nil
      custom_field_value.value.should be_nil
    end

    it "should update value to 'short text'" do
      custom_field_value.update(value: 'short text')
      custom_field_value.value.should eq('short text')
    end

    it "should not update value to 'abc'" do
      expect do
        custom_field_value.update!(value: 'abc')
      end.to raise_error(ActiveRecord::RecordInvalid, /string is too short \(minimum is 5\)/)
      custom_field_value.reload.value.should_not eq('abc')
    end

    it "should not update value to 'string is longer than 10'" do
      expect do
        custom_field_value.update!(value: 'string is longer than 10')
      end.to raise_error(ActiveRecord::RecordInvalid, /string is too long \(maximum is 10\)/)
      custom_field_value.reload.value.should_not eq('string is longer than 10')
    end

  end

  context "for type text" do
    let(:custom_field) { create(:test_run_custom_field_for_text, lower_limit: 5, upper_limit: 10)}

    let(:valid_attributes) do
      {
        custom_field_id: custom_field.id,
        value: 'test5',
        test_run_id: test_run.id
      }
    end

    let(:custom_field_value) do
      Tmt::TestRunCustomFieldValue.create(valid_attributes)
    end

    it "should create without value" do
      expect do
        Tmt::TestRunCustomFieldValue.create(valid_attributes.merge(value: nil))
      end.to change(Tmt::TestRunCustomFieldValue, :count).by(1)
    end

    it "should update value to 'short text'" do
      custom_field_value.update(value: 'short text')
      custom_field_value.value.should eq('short text')
    end

    it "should not update value to 'abc'" do
      expect do
        custom_field_value.update!(value: 'abc')
      end.to raise_error(ActiveRecord::RecordInvalid, /text is too short \(minimum is 5\)/)
      custom_field_value.reload.value.should_not eq('abc')
    end

    it "should not update value to 'string is longer than 10'" do
      expect do
        custom_field_value.update!(value: 'string is longer than 10')
      end.to raise_error(ActiveRecord::RecordInvalid, /text is too long \(maximum is 10\)/)
      custom_field_value.reload.value.should_not eq('string is longer than 10')
    end

  end

  context "for type bool" do
    let(:custom_field) { create(:test_run_custom_field_for_bool, default_value: false)}

    let(:valid_attributes) do
      {
        custom_field_id: custom_field.id,
        value: true,
        test_run_id: test_run.id
      }
    end

    let(:custom_field_value) do
      Tmt::TestRunCustomFieldValue.create(valid_attributes)
    end

    it "should create without value" do
      expect do
        Tmt::TestRunCustomFieldValue.create(valid_attributes.merge(value: nil))
      end.to change(Tmt::TestRunCustomFieldValue, :count).by(1)
    end

    it "should update value to true" do
      custom_field_value.update(value: true)
      custom_field_value.value.should be true
    end

    it "should update value to false" do
      custom_field_value.update(value: false)
      custom_field_value.value.should be false
    end

  end

  context "for type enumeration" do
    let(:custom_field) { create(:test_run_custom_field_for_enumeration)}

    let(:enumeration) do
      enumeration = custom_field.enumeration
      enumeration.values.create(text_value: 'first option', numerical_value: '1')
      enumeration.values.create(text_value: 'second option', numerical_value: '2')
      enumeration
    end

    let(:valid_attributes) do
      {
        custom_field_id: custom_field.id,
        test_run_id: test_run.id
      }
    end

    let(:custom_field_value) do
      Tmt::TestRunCustomFieldValue.create(valid_attributes)
    end

    it "should create without value" do
      value = nil
      expect do
        value = Tmt::TestRunCustomFieldValue.create(valid_attributes.merge(value: enumeration.values[1].numerical_value))
      end.to change(Tmt::TestRunCustomFieldValue, :count).by(1)
      value.enumeration.should eq(enumeration)
      value.enum_value.should eq(enumeration.values[1].numerical_value)
    end
  end

end
