# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :announcement do
    message "MyText"
    via_email false
    via_sms false
    user_id 1
  end
end
