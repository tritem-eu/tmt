# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :role, class: "Role" do
    name 'user'
  end
end
