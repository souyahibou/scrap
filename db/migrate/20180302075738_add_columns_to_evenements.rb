class AddColumnsToEvenements < ActiveRecord::Migration[5.1]
  def change
    add_column :evenements, :event_owner_id, :Text
    add_column :evenements, :changements, :Text
  end
end
