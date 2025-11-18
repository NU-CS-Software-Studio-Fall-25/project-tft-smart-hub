class CreatePendingRegistrations < ActiveRecord::Migration[8.0]
  def change
    create_table :pending_registrations do |t|
      t.string :email, null: false
      t.string :password_digest, null: false
      t.string :display_name
      t.string :verification_code, null: false
      t.datetime :code_sent_at, null: false
      t.datetime :expires_at, null: false

      t.timestamps
    end
    
    add_index :pending_registrations, :email, unique: true
    add_index :pending_registrations, :verification_code
    add_index :pending_registrations, :expires_at
  end
end
