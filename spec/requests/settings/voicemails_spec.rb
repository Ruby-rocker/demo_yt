require 'spec_helper'

describe "Settings::Voicemails" do
  describe "GET /settings/voicemails" do
  	it "displays all voicemails" do
      get settings_voicemails_path
      response.status.should be(404)
    end

    it "creates new voicemail with valid data" do
	     get new_settings_voicemail_path
	     voicemail = FactoryGirl.create(:voicemail)
	   end
  end

  describe "POST /create (#create)" do
  	it "should deliver the voicemail creation email" do
      voicemail = FactoryGirl.create(:voicemail)
      ClientMailer.voicemail_added(voicemail).deliver
	  end
  end
end
