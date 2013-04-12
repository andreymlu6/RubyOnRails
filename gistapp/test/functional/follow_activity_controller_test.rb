require 'test_helper'

class FollowActivityControllerTest < ActionController::TestCase
  test "should get follow" do
    get :follow
    assert_response :success
  end

  test "should get unfollow" do
    get :unfollow
    assert_response :success
  end

  test "should get update_follower" do
    get :update_follower
    assert_response :success
  end

end
