require 'test_helper'

class LandingHelperTest < ActionDispatch::IntegrationTest

  def setup
  end

  test "reqest Random Wiki" do
    get landing_home_path
    assert_response :success
  end
end

