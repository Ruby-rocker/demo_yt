# # Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :calendar do
  	ActsAsTenant.current_tenant = Tenant.first
  	# sequence(:seq_num, '1000') { |n| n=n+1 }
  	sequence(:name, 1) { |n| "test#{n}" }
  	color "#757779"
  	timezone "Mountain Time (US & Canada)"
  	apt_length "30"
  	business_id "1"
  	# calendar_auth_token "8c23567916cde7feb95620df8e68c089"
  end
end
