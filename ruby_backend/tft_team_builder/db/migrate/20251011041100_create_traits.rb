class CreateTraits < ActiveRecord::Migration[8.0]
  def change
    create_table :traits do |t|
      t.string :api_id
      t.string :name
      t.string :image_full
      t.string :image_sprite
      t.integer :image_x
      t.integer :image_y
      t.integer :image_w
      t.integer :image_h

      t.timestamps
    end
  end
end
