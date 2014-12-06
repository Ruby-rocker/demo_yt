require 'spec_helper'

describe "Appointments" do
  describe "GET /appointments" do
  	# it "displays all appointments" do
   #    get appointments_path
   #    response.status.should be(404)
   #  end

    it "creates new appointment with valid data" do
	     get new_appointment_path
	     appointment = FactoryGirl.create(:appointment)
	   end
  end

  describe "POST /create (#create)" do
  	it "should deliver the appointment creation email" do
      appointment = FactoryGirl.create(:appointment)
      ClientMailer.appointment_set(appointment, "dhara.joshi@softwebsolutions.com").deliver
	  end
  end
end
