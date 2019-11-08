# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :test_run_custom_field_value, :class => 'Tmt::TestRunCustomFieldValue' do
    test_run_id 1
    association :custom_field, factory: :test_run_custom_field_for_text
    text_value "My Text is longer than 10"
  end
end
