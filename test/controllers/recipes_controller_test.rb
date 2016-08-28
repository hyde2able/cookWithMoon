require 'test_helper'

class RecipesControllerTest < ActionDispatch::IntegrationTest
  test "should get show" do
    get recipes_show_url
    assert_response :success
  end

  test "should get share" do
    get recipes_share_url
    assert_response :success
  end

  test "should get tech" do
    get recipes_tech_url
    assert_response :success
  end

end
