# encoding: UTF-8
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

ActiveRecord::Schema.define(version: 20170521011422) do

  create_table "bids", force: :cascade do |t|
    t.integer  "hand_id"
    t.integer  "game_id"
    t.string   "suit"
    t.integer  "tricks"
    t.boolean  "won"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "cards", force: :cascade do |t|
    t.integer  "hand_id"
    t.integer  "game_id"
    t.integer  "trick_id"
    t.string   "rank"
    t.string   "suit"
    t.boolean  "is_trump",   default: false
    t.float    "strength"
    t.datetime "created_at",                 null: false
    t.datetime "updated_at",                 null: false
  end

  create_table "games", force: :cascade do |t|
    t.integer  "match_id"
    t.integer  "bid_winner_id"
    t.string   "trump_suit"
    t.integer  "tricks_bid"
    t.integer  "tricks_won"
    t.boolean  "started",       default: false
    t.boolean  "played",        default: false
    t.datetime "created_at",                    null: false
    t.datetime "updated_at",                    null: false
  end

  create_table "hands", force: :cascade do |t|
    t.integer  "game_id"
    t.integer  "user_id"
    t.integer  "bid_order"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "match_users", force: :cascade do |t|
    t.integer  "user_id"
    t.integer  "match_id"
    t.integer  "score",      default: 0, null: false
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
  end

  create_table "matches", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "tricks", force: :cascade do |t|
    t.integer  "game_id"
    t.integer  "won_by_hand_id"
    t.datetime "created_at",     null: false
    t.datetime "updated_at",     null: false
  end

  create_table "users", force: :cascade do |t|
    t.string   "email",                  default: "", null: false
    t.string   "encrypted_password",     default: "", null: false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          default: 0,  null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.boolean  "is_ai"
    t.datetime "created_at",                          null: false
    t.datetime "updated_at",                          null: false
  end

  add_index "users", ["email"], name: "index_users_on_email", unique: true
  add_index "users", ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true

end
