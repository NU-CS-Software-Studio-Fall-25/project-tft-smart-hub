class AddCountersToTeamComps < ActiveRecord::Migration[8.0]
  def change
    add_column :team_comps, :likes_count, :integer, default: 0, null: false
    add_column :team_comps, :favorites_count, :integer, default: 0, null: false
    add_column :team_comps, :comments_count, :integer, default: 0, null: false
  end
end
