require "test_helper"

class Api::TeamCompsControllerTest < ActionDispatch::IntegrationTest
  fixtures :champions, :team_comps

  test "index returns serialized comps with cards" do
    get api_team_comps_path, as: :json
    assert_response :success

    payload = JSON.parse(response.body)
    assert_equal TeamComp.count, payload.size
    assert payload.first["cards"].is_a?(Array), "expected cards array"
  end

  test "create comp from champion ids" do
    champion_ids = Champion.pluck(:id)
    body = {
      team_comp: {
        name: "Test From API",
        description: "Created via controller test",
        champion_ids: champion_ids,
        win_rate: 0.5,
        play_rate: 0.1
      }
    }

    assert_difference -> { TeamComp.count }, +1 do
      post api_team_comps_path, params: body, as: :json
      assert_response :created
    end

    payload = JSON.parse(response.body)
    assert_equal "Test From API", payload["name"]
    assert_equal Champion.count, payload["cards"].length
  end

  test "recommendations include match metadata" do
    include_ids = [champions(:one).id]

    post recommendations_api_team_comps_path,
         params: { include_cards: include_ids },
         as: :json

    assert_response :success
    payload = JSON.parse(response.body)
    assert_equal include_ids, payload["requestedChampionIds"]
    assert payload["teams"].first["meta"]["matchCount"] >= 0
  end
end
