# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :bonu, :class => 'Bonus' do
    partner_master_id 1
    bonus 1
  end
end
