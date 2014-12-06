# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :appointment do
    ActsAsTenant.current_tenant = Tenant.first
    calendar_id 1
    start_at "2014-02-21 12:02:39"
    end_at "2014-02-21 12:02:39"
    repeat 0
    schedule "MyText"
    timezone "MyString"
    contact_id 1
    phone_script_id 1
    via_xps 0
  end
end
