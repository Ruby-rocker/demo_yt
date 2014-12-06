require 'spec_helper'

describe "Calendars" do  
  describe "GET /calendars" do
  	it "displays all calendars" do
      get calendars_path
      response.status.should be(404)
    end

    it "creates new calendar with valid data" do
	     get new_settings_calendar_path
	     calendar = FactoryGirl.create(:calendar)
	   end
  end

  describe "POST /create (#create)" do
  	it "should deliver the calendar creation email" do
      calendar = FactoryGirl.create(:calendar)
      ClientMailer.calendar_created(calendar, "dhara.joshi@softwebsolutions.com").deliver
	  end
  end
end
