require 'test_helper'

class LandingControllerTest < ActionDispatch::IntegrationTest
  test "should get home" do
    get landing_home_url
    assert_response :success
  end

end
