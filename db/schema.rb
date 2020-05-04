# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `rails
# db:schema:load`. When creating a new database, `rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 2020_05_04_201349) do

  create_table "games", force: :cascade do |t|
    t.string "name", null: false
    t.integer "current_turn", default: 1
    t.string "era"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.decimal "port"
  end

  create_table "player_games", force: :cascade do |t|
    t.string "nation", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "game_id"
    t.integer "player_id"
    t.index ["game_id"], name: "index_player_games_on_game_id"
    t.index ["player_id"], name: "index_player_games_on_player_id"
  end

  create_table "players", force: :cascade do |t|
    t.text "username"
  end

  create_table "stats", force: :cascade do |t|
    t.integer "turn", null: false
    t.text "raw_stats"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "games_id"
    t.index ["games_id"], name: "index_stats_on_games_id"
  end

end
