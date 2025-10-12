class CreateTeamComps < ActiveRecord::Migration[8.0]
  def change
    create_table :team_comps do |t|
      t.string :name
      t.text :description
      t.string :champions

      t.timestamps
    end
  end
end
