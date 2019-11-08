# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :user_activity, class: "Tmt::UserActivity" do
    user_id 1
    observable_id 1
    observable_type "MyString"
    params({parser: :custom_field})
    param_name "MyString"
    before_value "MyString"
    after_value "MyString"
    association :project, factory: :project
  end
end
