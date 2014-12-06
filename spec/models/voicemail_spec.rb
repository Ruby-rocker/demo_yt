require 'spec_helper'

describe Voicemail do
	it { should belong_to(:tenant) }
	it { should belong_to(:business) }

	it { should have_many(:email_ids) }
	it { should have_many(:subscriptions) }
	it { should have_many(:billing_transactions) }
	it { should have_many(:notifications) }
	
	it { should have_one(:add_on) }
	it { should have_one(:twilio_number) }
	it { should have_one(:audio_file) }
end
