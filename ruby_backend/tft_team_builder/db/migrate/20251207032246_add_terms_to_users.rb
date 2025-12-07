class AddTermsToUsers < ActiveRecord::Migration[8.0]
  def change
    add_column :users, :terms_accepted, :boolean, default: false, null: false
    add_column :users, :terms_accepted_at, :datetime
    add_index :users, :terms_accepted
  end
end
