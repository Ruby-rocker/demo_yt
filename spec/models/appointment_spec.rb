require 'spec_helper'

describe Appointment do
	it { should belong_to(:tenant) }
	it { should belong_to(:calendar) }
	it { should belong_to(:contact) }
	it { should belong_to(:user) }
	it { should belong_to(:phone_script) }

  it { should have_many(:notifications) }
end
