# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :cfg, class: "Tmt::Cfg" do
    instance_name "MyString"
  end
end
