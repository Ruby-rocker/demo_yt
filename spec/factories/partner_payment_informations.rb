# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :partner_payment_information do
    partner_master_id 1
    paypal_email "MyString"
    ssn "MyString"
    type ""
  end
end
