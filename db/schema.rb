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

ActiveRecord::Schema.define(version: 20160410031552) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "arts", force: :cascade do |t|
    t.string   "name"
    t.string   "creator"
    t.datetime "creation_date"
    t.datetime "created_at",    null: false
    t.datetime "updated_at",    null: false
    t.text     "description"
  end

  create_table "competitions", force: :cascade do |t|
    t.integer  "challenger_id"
    t.integer  "art_id"
    t.integer  "winner_id"
    t.datetime "created_at",    null: false
    t.datetime "updated_at",    null: false
    t.index ["art_id"], name: "index_competitions_on_art_id", using: :btree
    t.index ["challenger_id"], name: "index_competitions_on_challenger_id", using: :btree
    t.index ["winner_id"], name: "index_competitions_on_winner_id", using: :btree
  end

  add_foreign_key "competitions", "arts"
end
