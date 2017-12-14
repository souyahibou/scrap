require 'test_helper'

class ScrappingControllerTest < ActionDispatch::IntegrationTest
  test "should get home" do
    get scrapping_home_url
    assert_response :success
  end

end
