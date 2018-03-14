# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20180313143055) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "evenements", force: :cascade do |t|
    t.string "event_id"
    t.string "event_name"
    t.string "event_start_time"
    t.string "event_end_time"
    t.string "event_description"
    t.string "event_place_id"
    t.string "event_place_name"
    t.string "event_place_location_data"
    t.string "change"
    t.string "event_place_city"
    t.string "event_place_country"
    t.string "event_place_latitude"
    t.string "event_place_longitude"
    t.string "event_place_street"
    t.string "event_place_zip"
    t.string "event_event_times_data"
    t.string "event_owner_name"
    t.string "event_photos_images"
    t.string "last_date"
    t.string "groupe_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "origin_base"
    t.text "event_owner_id"
    t.text "changements"
    t.index ["origin_base"], name: "index_evenements_on_origin_base"
  end

  create_table "stages", force: :cascade do |t|
    t.string "Nombre_de_places"
    t.string "Période"
    t.text "Duree"
    t.string "Niveau_demandé"
    t.text "Descriptif"
    t.text "Autres_commentaires"
    t.string "Logement"
    t.string "Restauration"
    t.string "précision_durée"
    t.string "employeur"
    t.string "localisation"
    t.string "etablissement"
    t.string "adresse"
    t.string "adresse_militaire"
    t.string "Identité"
    t.string "Adresse_mèl"
    t.string "Téléphone"
    t.string "Fax"
    t.string "Fonction"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

end
