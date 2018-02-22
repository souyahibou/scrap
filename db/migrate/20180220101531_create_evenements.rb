class CreateEvenements < ActiveRecord::Migration[5.1]
  def change
    create_table :evenements do |t|
      t.string :event_id
      t.string :event_name
      t.string :event_start_time
      t.string :event_end_time
      t.string :event_description
      t.string :event_place_id
      t.string :event_place_name
      t.string :event_place_location_data
      t.string :change
      t.string :event_place_city
      t.string :event_place_country
      t.string :event_place_latitude
      t.string :event_place_longitude
      t.string :event_place_street
      t.string :event_place_zip
      t.string :event_event_times_data
      t.string :event_owner_name
      t.string :event_photos_images
      t.string :last_date
      t.string :groupe_id

      t.timestamps
    end
  end
end
