require "test_helper"

class TeamCompTest < ActiveSupport::TestCase
  fixtures :team_comps

  test "champion_names returns normalized array" do
    comp = team_comps(:one)
    assert_equal [ "Aatrox", "Kayle" ], comp.champion_names
  end

  test "win_rate_value converts to float" do
    comp = team_comps(:one)
    assert_in_delta 0.55, comp.win_rate_value, 0.0001
  end

  test "validates presence of name and champions" do
    comp = TeamComp.new
    assert_not comp.valid?
    assert_includes comp.errors.messages[:name], "can't be blank"
    assert_includes comp.errors.messages[:champions], "can't be blank"
  end
end
