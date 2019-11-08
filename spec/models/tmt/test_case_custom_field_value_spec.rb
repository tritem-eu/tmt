require 'spec_helper'

describe Tmt::TestCaseCustomFieldValue do
  let(:project) { create(:project) }
  let(:creator) { create(:user) }

  let(:test_case) { create(:test_case, project: project, creator: creator) }
  let(:custom_field_category) { Tmt::TestCaseCustomField.where(name: :category).last}
  let(:custom_field_spent_time) { Tmt::TestCaseCustomField.where(name: :spent_time).last}

  let(:valid_attributes) do 
    {
      custom_field_id: custom_field_category.id,
      value: "Category 1",
      test_case_id: test_case.id
    }
  end

  let(:klass) { Tmt::TestCaseCustomFieldValue }

  let(:value) { klass.create(valid_attributes) }

  it "should properly valid new custom field value" do
    klass.new(valid_attributes).should be_valid
  end

  it "should properly create value of custom field" do
    value.reload.string_value.should eql("Category 1")
    value.reload.text_value.should be_nil
    value.value.should eq("Category 1")
  end

  it "should properly properly change of custom field" do
    value.reload.string_value.should eql("Category 1")
    value.custom_field = custom_field_spent_time
    time = Time.now
    value.value = time
    value.string_value.should be_nil
    value.date_value.should eq(time)
  end

  it "should return name of type" do
    value.type_name.should eq(:string)
  end

  it "should return custom field name" do
    value.custom_field_name.should eq(:category)
  end

  context "for type int" do
    let(:custom_field) { create(:test_case_custom_field_for_integer, lower_limit: -10, upper_limit: 100)}
    let(:valid_attributes) do
      {
        custom_field_id: custom_field.id,
        value: 37,
        test_case_id: test_case.id
      }
    end

    let(:custom_field_value) do
      Tmt::TestCaseCustomFieldValue.create(valid_attributes)
    end

    it "should create without value" do
      expect do
        Tmt::TestCaseCustomFieldValue.create(valid_attributes.merge(value: nil))
      end.to change(Tmt::TestCaseCustomFieldValue, :count).by(1)
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
    let(:custom_field) { create(:test_case_custom_field, lower_limit: 5, upper_limit: 10)}

    let(:valid_attributes) do
      {
        custom_field_id: custom_field.id,
        value: 'test5',
        test_case_id: test_case.id
      }
    end

    let(:custom_field_value) do
      Tmt::TestCaseCustomFieldValue.create(valid_attributes)
    end

    it "should create without value" do
      expect do
        Tmt::TestCaseCustomFieldValue.create(valid_attributes.merge(value: nil))
      end.to change(Tmt::TestCaseCustomFieldValue, :count).by(1)
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
    let(:custom_field) { create(:test_case_custom_field_for_text, lower_limit: 5, upper_limit: 10)}

    let(:valid_attributes) do
      {
        custom_field_id: custom_field.id,
        value: 'test5',
        test_case_id: test_case.id
      }
    end

    let(:custom_field_value) do
      Tmt::TestCaseCustomFieldValue.create(valid_attributes)
    end

    it "should create without value" do
      expect do
        Tmt::TestCaseCustomFieldValue.create(valid_attributes.merge(value: nil))
      end.to change(Tmt::TestCaseCustomFieldValue, :count).by(1)
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
    let(:custom_field) { create(:test_case_custom_field_for_bool, default_value: false)}

    let(:valid_attributes) do
      {
        custom_field_id: custom_field.id,
        value: true,
        test_case_id: test_case.id
      }
    end

    let(:custom_field_value) do
      Tmt::TestCaseCustomFieldValue.create(valid_attributes)
    end

    it "should create without value" do
      expect do
        Tmt::TestCaseCustomFieldValue.create(valid_attributes.merge(value: nil))
      end.to change(Tmt::TestCaseCustomFieldValue, :count).by(1)
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
    let(:custom_field) {
      create(:test_case_custom_field_for_enumeration)
    }

    let(:enumeration) do
      enumeration = custom_field.enumeration
      enumeration.values.create(text_value: 'first option', numerical_value: '1')
      enumeration.values.create(text_value: 'second option', numerical_value: '2')
      enumeration
    end

    let(:valid_attributes) do
      {
        custom_field_id: custom_field.id,
        test_case_id: test_case.id
      }
    end

    let(:custom_field_value) do
      Tmt::TestCaseCustomFieldValue.create(valid_attributes)
    end

    it "should create without value" do
      value = nil
      expect do
        value = Tmt::TestCaseCustomFieldValue.create(valid_attributes.merge(value: enumeration.values[1].numerical_value))
      end.to change(Tmt::TestCaseCustomFieldValue, :count).by(1)
      value.enumeration.should eq(enumeration)
      value.enum_value.should eq(enumeration.values[1].numerical_value)
    end
  end

end
