# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :credit_amount do
    tenant_id 1
    amount "9.99"
  end
end
