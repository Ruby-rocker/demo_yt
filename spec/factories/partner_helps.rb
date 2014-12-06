# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :partner_help do
    tenant_id 1
    user_id 1
    details "MyString"
    first_name "MyString"
    last_name "MyString"
    area_code 1
    phone1 1
    phone2 1
    email "MyString"
  end
end
