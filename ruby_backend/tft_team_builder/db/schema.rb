# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[8.0].define(version: 2025_10_26_090500) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "champions", force: :cascade do |t|
    t.string "name"
    t.integer "tier"
    t.string "traits"
    t.string "image_url"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "sprite_name"
    t.integer "sprite_x"
    t.integer "sprite_y"
    t.integer "sprite_w"
    t.integer "sprite_h"
    t.string "api_id"
    t.integer "cost"
    t.string "set_identifier"
    t.index ["set_identifier", "api_id"], name: "index_champions_on_set_identifier_and_api_id", unique: true
    t.index ["set_identifier"], name: "index_champions_on_set_identifier"
  end

  create_table "team_comps", force: :cascade do |t|
    t.string "name"
    t.text "description"
    t.string "champions"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.decimal "win_rate", precision: 5, scale: 4
    t.decimal "play_rate", precision: 5, scale: 4
    t.text "notes"
    t.string "source"
    t.string "set_identifier"
    t.string "composition_key"
    t.string "composition_hash"
    t.integer "size"
    t.integer "play_count"
    t.integer "win_count"
    t.integer "top4_count"
    t.decimal "avg_placement", precision: 4, scale: 2
    t.decimal "top1_rate", precision: 5, scale: 4
    t.decimal "top2_rate", precision: 5, scale: 4
    t.decimal "top3_rate", precision: 5, scale: 4
    t.decimal "top4_rate", precision: 5, scale: 4
    t.jsonb "raw_data", default: {}, null: false
    t.index ["composition_hash"], name: "index_team_comps_on_composition_hash", unique: true
    t.index ["composition_key"], name: "index_team_comps_on_composition_key"
    t.index ["play_count"], name: "index_team_comps_on_play_count"
    t.index ["play_rate"], name: "index_team_comps_on_play_rate"
    t.index ["set_identifier"], name: "index_team_comps_on_set_identifier"
    t.index ["win_rate"], name: "index_team_comps_on_win_rate"
  end

  create_table "traits", force: :cascade do |t|
    t.string "api_id"
    t.string "name"
    t.string "image_full"
    t.string "image_sprite"
    t.integer "image_x"
    t.integer "image_y"
    t.integer "image_w"
    t.integer "image_h"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "set_identifier"
    t.index ["set_identifier", "api_id"], name: "index_traits_on_set_identifier_and_api_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "email", null: false
    t.string "password_digest", null: false
    t.string "role", default: "user", null: false
    t.string "display_name"
    t.text "bio"
    t.string "location"
    t.string "avatar_url"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["role"], name: "index_users_on_role"
  end
end
