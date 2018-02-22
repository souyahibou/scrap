class AddOriginBaseToEvenement < ActiveRecord::Migration[5.1]
  def change
    add_column :evenements, :origin_base, :string
    add_index :evenements, :origin_base
  end
end
