# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :user do
    sequence(:name) { |item| "Test User: #{item}"}
    sequence(:email) { |item| "example_#{item}@example.com" }
    password 'changeme'
    password_confirmation 'changeme'
    # required if the Devise Confirmable module is used
    confirmed_at Time.now

    factory :admin do
      before(:create, :stub) { |object| object.add_role(:admin) }
    end
  end

end
