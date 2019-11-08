# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :set, :class => 'Tmt::Set' do
    name "MyString"
    parent nil
    association :project, factory: :project
  end
end
