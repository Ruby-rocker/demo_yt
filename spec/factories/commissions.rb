# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :commission do
    user_id 1
    partner_master_id 1
    commission "9.99"
    is_paid false
  end
end
