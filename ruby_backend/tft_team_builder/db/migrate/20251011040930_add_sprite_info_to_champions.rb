class AddSpriteInfoToChampions < ActiveRecord::Migration[8.0]
  def change
    add_column :champions, :sprite_name, :string
    add_column :champions, :sprite_x, :integer
    add_column :champions, :sprite_y, :integer
    add_column :champions, :sprite_w, :integer
    add_column :champions, :sprite_h, :integer
  end
end
