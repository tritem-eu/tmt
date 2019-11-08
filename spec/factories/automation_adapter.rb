# Read about factories at https://github.com/thoughtbot/factory_girl
FactoryGirl.define do
  factory :automation_adapter, class: "Tmt::AutomationAdapter" do
    sequence(:name) { |n| "Automation Adapter (#{n})" }
    adapter_type Tmt.config[:oslc][:execution_adapter_type][:id]
    association :project, factory: :project
    association :user, factory: :user
    polling_interval 23
  end
end
