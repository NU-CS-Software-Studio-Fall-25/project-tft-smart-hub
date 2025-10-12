class CreateChampions < ActiveRecord::Migration[8.0]
  def change
    create_table :champions do |t|
      t.string :name
      t.integer :cost
      t.string :traits
      t.string :image_url

      t.timestamps
    end
  end
end
