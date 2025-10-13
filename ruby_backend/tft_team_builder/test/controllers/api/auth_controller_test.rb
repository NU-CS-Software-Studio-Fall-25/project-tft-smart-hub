require "test_helper"

class Api::AuthControllerTest < ActionDispatch::IntegrationTest
  setup do
    User.delete_all
  end

  test "register creates user and returns token" do
    post api_auth_register_path,
         params: {
           user: {
             email: "newuser@example.com",
             password: "Password123!",
             password_confirmation: "Password123!"
           }
         },
         as: :json

    assert_response :created
    payload = JSON.parse(response.body)
    assert payload["token"].present?
    assert_equal "newuser@example.com", payload["user"]["email"]
    assert_equal "user", payload["user"]["role"]
  end

  test "login returns token for valid credentials" do
    user = User.create!(email: "login@example.com", password: "Password123!", role: "admin")

    post api_auth_login_path,
         params: {
           user: { email: "login@example.com", password: "Password123!" }
         },
         as: :json

    assert_response :success
    payload = JSON.parse(response.body)
    assert payload["token"].present?
    assert_equal user.id, payload["user"]["id"]
  end
end
