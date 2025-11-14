class AddUserIdToTeamComps < ActiveRecord::Migration[8.0]
  def change
    add_column :team_comps, :user_id, :integer
  end
end
