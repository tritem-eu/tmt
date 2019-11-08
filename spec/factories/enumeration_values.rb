# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :enumeration_value, class: "Tmt::EnumerationValue" do
    enumeration_id 1
    numerical_value 1
    text_value "MyString"
  end
end
