# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :enumeration, class: "Tmt::Enumeration" do
    association :test_case_custom_field, factory: :test_case_custom_field_for_string
    name "MyString"
  end

  factory :enumeration_unassigned, class: "Tmt::Enumeration" do
    name "Priorities"
    test_case_custom_field_id nil
    test_run_custom_field_id nil
  end

  factory :enumeration_for_priorities, class: "Tmt::Enumeration" do
    name "Priorities"
    after(:create) do |enumeration, evaluator|
      ['mirror', 'medium', 'high'].each_with_index do |value, index|
        create(:enumeration_value, enumeration_id: evaluator.id, numerical_value: index, text_value: value)
      end
    end

  end

  factory :enumeration_for_test_run, class: "Tmt::Enumeration" do
    association :test_run_custom_field, factory: :test_run_custom_field_for_string

    name "Priorities"
    after(:create) do |enumeration, evaluator|
      ['mirror', 'medium', 'high'].each_with_index do |value, index|
        create(:enumeration_value, enumeration_id: evaluator.id, numerical_value: index, text_value: value)
      end
    end
  end

  factory :enumeration_for_test_case, class: "Tmt::Enumeration" do
    association :test_case_custom_field, factory: :test_case_custom_field_for_string

    name "Priorities"
    after(:create) do |enumeration, evaluator|
      ['mirror', 'medium', 'high'].each_with_index do |value, index|
        create(:enumeration_value, enumeration_id: evaluator.id, numerical_value: index, text_value: value)
      end
    end
  end

end
