require 'spec_helper'

describe PhoneMenu do
	it { should belong_to(:tenant) }
	it { should belong_to(:business) }

	it { should have_many(:phone_menu_keys) }
	it { should have_many(:digit_keys) }
	it { should have_many(:subscriptions) }
	it { should have_many(:billing_transactions) }
	it { should have_many(:notifications) }
	
	it { should have_one(:other_key) }
	it { should have_one(:twilio_number) }
	it { should have_one(:audio_file) }
	it { should have_one(:add_on) }
end
