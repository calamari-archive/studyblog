require 'test_helper'

class StudiesControllerTest < ActionController::TestCase
  setup do
    @study = studies(:adminOne)
  end

  test "should get index of two admins" do
    UserSession.create users(:admin)
    get :index
    assert_response :success
    assert_not_nil assigns(:studies)
    assert_equal 4, assigns(:studies).length, "admins should see all studies"

    UserSession.create users(:admin2)
    get :index
    assert_response :success
    assert_not_nil assigns(:studies)
    assert_equal 4, assigns(:studies).length, "admins should see all studies"
  end

end
