require 'spec_helper'

describe "PhoneMenus" do
  describe "GET /settings/phone_menus" do
  	it "displays all phone menus" do
      get settings_phone_menus_path
      response.status.should be(404)
    end

    it "creates new phone menu with valid data" do
	     get new_settings_phone_menu_path
	     phone_menu = FactoryGirl.create(:phone_menu)
	   end
  end

  describe "POST /create (#create)" do
  	it "should deliver the phone menu creation email" do
      phone_menu = FactoryGirl.create(:phone_menu)
      ClientMailer.phone_menu_created(phone_menu).deliver
	  end
  end
end
