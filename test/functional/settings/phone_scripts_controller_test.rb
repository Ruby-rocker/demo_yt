require 'test_helper'

class Settings::PhoneScriptsControllerTest < ActionController::TestCase
  test "should get index" do
    get :index
    assert_response :success
  end

end
