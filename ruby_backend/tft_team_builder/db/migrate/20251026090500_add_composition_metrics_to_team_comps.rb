class AddCompositionMetricsToTeamComps < ActiveRecord::Migration[8.0]
  def change
    add_column :team_comps, :set_identifier, :string
    add_column :team_comps, :composition_key, :string
    add_column :team_comps, :composition_hash, :string
    add_column :team_comps, :size, :integer
    add_column :team_comps, :play_count, :integer
    add_column :team_comps, :win_count, :integer
    add_column :team_comps, :top4_count, :integer
    add_column :team_comps, :avg_placement, :decimal, precision: 4, scale: 2
    add_column :team_comps, :top1_rate, :decimal, precision: 5, scale: 4
    add_column :team_comps, :top2_rate, :decimal, precision: 5, scale: 4
    add_column :team_comps, :top3_rate, :decimal, precision: 5, scale: 4
    add_column :team_comps, :top4_rate, :decimal, precision: 5, scale: 4
    add_column :team_comps, :raw_data, :jsonb, default: {}, null: false

    add_index :team_comps, :set_identifier
    add_index :team_comps, :composition_hash, unique: true
    add_index :team_comps, :composition_key
    add_index :team_comps, :play_count
  end
end
