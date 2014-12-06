# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :phone_menu do
  	ActsAsTenant.current_tenant = Tenant.first
  	sequence(:name, 1) { |n| "test#{n}" }
  	business_id "1"
  	is_deleted "0"
  end
end
