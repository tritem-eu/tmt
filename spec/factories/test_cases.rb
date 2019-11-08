# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :test_case, class: "Tmt::TestCase" do
    name "MyString"
    association :project, factory: :project
    association :creator, factory: :user
    association :type, factory: :test_case_type

    factory :test_case_with_type_file do
      association :type, factory: :test_case_type_file
    end
  end
end
