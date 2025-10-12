# frozen_string_literal: true

class AddMetadataToTeamComps < ActiveRecord::Migration[8.0]
  def change
    add_column :team_comps, :win_rate, :decimal, precision: 5, scale: 4
    add_column :team_comps, :play_rate, :decimal, precision: 5, scale: 4
    add_column :team_comps, :notes, :text
    add_column :team_comps, :source, :string
    add_index :team_comps, :win_rate
    add_index :team_comps, :play_rate
  end
end
