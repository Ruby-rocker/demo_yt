# Read about factories at https://github.com/thoughtbot/factory_girl

# FactoryGirl.define do
#   factory :user do
#   	ActsAsTenant.current_tenant = Tenant.first
#     sequence(:seq_num, '1000') { |n| n=n+1 }
#     tenant_id 1
#     email { "test#{seq_num}@example.com" }
#     password "foobar123"
#     password_confirmation "foobar123"
#     first_name { "test#{seq_num}" }
#     last_name { "test#{seq_num}" }
#     subdomain { "softweb#{seq_num}" }
#     role "1"
#     status "active"
#   end
# end
