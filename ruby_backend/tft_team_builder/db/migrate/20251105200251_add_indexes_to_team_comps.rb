class AddIndexesToTeamComps < ActiveRecord::Migration[8.0]
  def change
    # Index for sorting by win_rate (most common query)
    add_index :team_comps, :win_rate, if_not_exists: true
    
    # Composite index for sorting by win_rate and created_at together
    add_index :team_comps, [:win_rate, :created_at], if_not_exists: true
    
    # Index for set_identifier filtering
    add_index :team_comps, :set_identifier, if_not_exists: true
    
    # Index for name search (case-insensitive)
    # Note: For LIKE queries, consider using pg_trgm extension for better performance
    add_index :team_comps, "LOWER(name)", name: "index_team_comps_on_lower_name", if_not_exists: true
  end
end
