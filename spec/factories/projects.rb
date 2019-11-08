# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :project, class: "Tmt::Project" do
    sequence(:name) { |item| "My String #{item}"}
    association :creator, factory: :user
  end
end
