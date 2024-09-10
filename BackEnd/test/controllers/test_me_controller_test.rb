require "test_helper"

class TestMeControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get test_me_index_url
    assert_response :success
  end
end
