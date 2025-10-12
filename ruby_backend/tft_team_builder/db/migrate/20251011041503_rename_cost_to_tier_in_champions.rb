class RenameCostToTierInChampions < ActiveRecord::Migration[8.0]
  def change
    rename_column :champions, :cost, :tier
  end
end
