class AddImportColumnsToChampionsAndTraits < ActiveRecord::Migration[8.0]
  def change
    add_column :champions, :api_id, :string
    add_column :champions, :cost, :integer
    add_column :champions, :set_identifier, :string

    add_index :champions, :set_identifier
    add_index :champions, [:set_identifier, :api_id], unique: true

    add_column :traits, :set_identifier, :string
    add_index :traits, [:set_identifier, :api_id]
  end
end
