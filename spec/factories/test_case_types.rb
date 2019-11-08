# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :test_case_type, class: "Tmt::TestCaseType" do
    sequence(:name) { |item| "My String #{item}"}

    has_file false
    extension ""
    converter "sequence"

    factory :test_case_type_file do
      has_file true
    end
  end
end
