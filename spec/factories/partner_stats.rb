# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :partner_stat do
    ip_address "MyString"
    partner_master_id 1
    clicks 1
  end
end
