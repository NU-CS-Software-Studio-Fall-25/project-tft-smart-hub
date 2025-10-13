# frozen_string_literal: true

class CreateUsers < ActiveRecord::Migration[8.0]
  def change
    create_table :users do |t|
      t.string :email, null: false
      t.string :password_digest, null: false
      t.string :role, null: false, default: "user"
      t.string :display_name
      t.text :bio
      t.string :location
      t.string :avatar_url

      t.timestamps
    end

    add_index :users, :email, unique: true
    add_index :users, :role
  end
end
