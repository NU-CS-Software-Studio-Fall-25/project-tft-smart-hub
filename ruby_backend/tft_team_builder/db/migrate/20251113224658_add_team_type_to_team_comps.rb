class AddTeamTypeToTeamComps < ActiveRecord::Migration[8.0]
  def change
    add_column :team_comps, :team_type, :string, default: 'user'
  end
end
