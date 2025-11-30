require "test_helper"

class S3TestControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get s3_test_index_url
    assert_response :success
  end
end
