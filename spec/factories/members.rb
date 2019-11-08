# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :member, class: "Tmt::Member" do
    association :project, factory: :project
    association :user, factory: :user
  end
end
