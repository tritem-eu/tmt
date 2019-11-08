# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :external_relationship, class: "Tmt::ExternalRelationship" do
    value "MyString"
    url 'http://www.example.com'
    association :source, factory: :test_case
  end
end
