require 'spec_helper'

describe Calendar do
  it { should belong_to(:tenant) }
	it { should belong_to(:business) }

  it { should have_many(:calendar_hours) }
  it { should have_many(:appointments) }
  it { should have_many(:blocked_timings) }
  it { should have_many(:phone_scripts) }
  it { should have_many(:notifications) }
end
