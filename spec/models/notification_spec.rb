require 'spec_helper'

describe Notification do
	it { should belong_to(:tenant) }
	it { should belong_to(:notifiable) }

	it { should have_many(:user_notifications) }
	it { should have_many(:users) }
end
