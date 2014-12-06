# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :voicemail do
    ActsAsTenant.current_tenant = Tenant.first
    name "MyString"
    business_id 1
    is_deleted "0"
  end
end
