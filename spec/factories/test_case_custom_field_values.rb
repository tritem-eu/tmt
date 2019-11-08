# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :test_case_custom_field_value, :class => 'Tmt::TestCaseCustomFieldValue' do
    test_case_id 1
    association :custom_field, factory: :test_case_custom_field_for_text
    text_value "My Text is longer than 10"
  end
end
