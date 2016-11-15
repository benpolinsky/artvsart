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

ActiveRecord::Schema.define(version: 20161115013656) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "arts", force: :cascade do |t|
    t.string   "name"
    t.string   "creator"
    t.datetime "creation_date"
    t.datetime "created_at",                    null: false
    t.datetime "updated_at",                    null: false
    t.text     "description"
    t.integer  "status",            default: 0
    t.string   "image"
    t.integer  "win_count",         default: 0
    t.integer  "loss_count",        default: 0
    t.text     "additional_images"
    t.string   "source"
    t.integer  "category_id"
    t.string   "slug"
    t.string   "source_link"
    t.integer  "elo_rating"
    t.index ["category_id"], name: "index_arts_on_category_id", using: :btree
    t.index ["elo_rating"], name: "index_arts_on_elo_rating", using: :btree
  end

  create_table "authorization_tokens", force: :cascade do |t|
    t.string   "service"
    t.text     "token"
    t.datetime "expires_on"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "categories", force: :cascade do |t|
    t.string   "name"
    t.integer  "art_count",  default: 0
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
    t.string   "color"
    t.string   "slug"
    t.integer  "parent_id"
    t.index ["parent_id"], name: "index_categories_on_parent_id", using: :btree
  end

  create_table "competitions", force: :cascade do |t|
    t.integer  "challenger_id"
    t.integer  "art_id"
    t.integer  "winner_id"
    t.datetime "created_at",    null: false
    t.datetime "updated_at",    null: false
    t.integer  "loser_id"
    t.integer  "user_id"
    t.string   "slug"
    t.index ["art_id"], name: "index_competitions_on_art_id", using: :btree
    t.index ["challenger_id"], name: "index_competitions_on_challenger_id", using: :btree
    t.index ["loser_id"], name: "index_competitions_on_loser_id", using: :btree
    t.index ["user_id"], name: "index_competitions_on_user_id", using: :btree
    t.index ["winner_id"], name: "index_competitions_on_winner_id", using: :btree
  end

  create_table "friendly_id_slugs", force: :cascade do |t|
    t.string   "slug",                      null: false
    t.integer  "sluggable_id",              null: false
    t.string   "sluggable_type", limit: 50
    t.string   "scope"
    t.datetime "created_at"
    t.index ["slug", "sluggable_type", "scope"], name: "index_friendly_id_slugs_on_slug_and_sluggable_type_and_scope", unique: true, using: :btree
    t.index ["slug", "sluggable_type"], name: "index_friendly_id_slugs_on_slug_and_sluggable_type", using: :btree
    t.index ["sluggable_id"], name: "index_friendly_id_slugs_on_sluggable_id", using: :btree
    t.index ["sluggable_type"], name: "index_friendly_id_slugs_on_sluggable_type", using: :btree
  end

  create_table "identities", force: :cascade do |t|
    t.integer  "user_id"
    t.string   "provider"
    t.string   "uid"
    t.text     "token"
    t.text     "secret"
    t.datetime "expires_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_identities_on_user_id", using: :btree
  end

  create_table "users", force: :cascade do |t|
    t.string   "email",                     default: "",    null: false
    t.string   "encrypted_password",        default: "",    null: false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",             default: 0,     null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.inet     "current_sign_in_ip"
    t.inet     "last_sign_in_ip"
    t.datetime "created_at",                                null: false
    t.datetime "updated_at",                                null: false
    t.string   "auth_token",                default: ""
    t.boolean  "admin",                     default: false
    t.string   "type"
    t.integer  "judged_competitions_count", default: 0
    t.integer  "rank"
    t.string   "confirmation_token"
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.string   "username"
    t.datetime "deleted_at"
    t.index ["auth_token"], name: "index_users_on_auth_token", using: :btree
    t.index ["confirmation_token"], name: "index_users_on_confirmation_token", unique: true, using: :btree
    t.index ["deleted_at"], name: "index_users_on_deleted_at", using: :btree
    t.index ["email"], name: "index_users_on_email", unique: true, using: :btree
    t.index ["rank"], name: "index_users_on_rank", using: :btree
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true, using: :btree
    t.index ["username"], name: "index_users_on_username", using: :btree
  end

  add_foreign_key "arts", "categories"
  add_foreign_key "competitions", "arts", on_delete: :nullify
  add_foreign_key "competitions", "users"
  add_foreign_key "identities", "users"
end
