require "test_helper"

class Api::ChampionsControllerTest < ActionDispatch::IntegrationTest
  fixtures :champions

  test "returns champion collection" do
    get api_champions_path, as: :json
    assert_response :success

    payload = JSON.parse(response.body)
    assert_equal Champion.count, payload.size
    assert payload.first.key?("imageUrl"), "expected imageUrl field"
  end

  test "returns single champion" do
    champion = champions(:one)

    get api_champion_path(champion), as: :json
    assert_response :success

    payload = JSON.parse(response.body)
    assert_equal champion.name, payload["name"]
    assert_equal champion.tier, payload["tier"]
  end
end
