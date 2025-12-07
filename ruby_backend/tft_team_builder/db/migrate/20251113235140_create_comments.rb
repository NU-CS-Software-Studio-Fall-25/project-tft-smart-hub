class CreateComments < ActiveRecord::Migration[8.0]
  def change
    create_table :comments do |t|
      t.references :user, null: false, foreign_key: true
      t.references :team_comp, null: false, foreign_key: true
      t.text :content

      t.timestamps
    end

    add_index :comments, :created_at
  end
end
