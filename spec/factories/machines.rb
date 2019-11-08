FactoryGirl.define do
  factory :machine, class: 'Tmt::Machine' do
    ip_address '127.0.0.1'
    hostname 'www'
    fully_qualified_domain_name 'www.example.com'
    mac_address 'ff:ff:ff:ff:ff:ff'
    association :user, factory: :user
  end
end
