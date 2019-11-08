# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :campaign, class: "Tmt::Campaign" do
    sequence(:name) { |n| "MyString#{n}" }
    is_open true
    association :project, factory: :project
  end
end
