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
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20101110201512) do

  create_table "locations", :force => true do |t|
    t.string   "raw_location",     :null => false
    t.float    "lat",              :null => false
    t.float    "lng",              :null => false
    t.string   "street_address"
    t.string   "city",             :null => false
    t.string   "province",         :null => false
    t.string   "district"
    t.string   "state",            :null => false
    t.string   "zip"
    t.string   "country",          :null => false
    t.string   "country_code",     :null => false
    t.integer  "accuracy",         :null => false
    t.string   "precision",        :null => false
    t.string   "suggested_bounds", :null => false
    t.string   "provider",         :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "pairing_sessions", :force => true do |t|
    t.string   "description"
    t.integer  "owner_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "start_at",        :null => false
    t.datetime "end_at",          :null => false
    t.integer  "pair_id"
    t.integer  "location_id"
    t.string   "location_detail"
  end

  create_table "users", :force => true do |t|
    t.string   "email",                               :default => "", :null => false
    t.string   "encrypted_password",   :limit => 128, :default => "", :null => false
    t.string   "password_salt",                       :default => "", :null => false
    t.string   "reset_password_token"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "first_name"
    t.string   "last_name"
    t.integer  "location_id"
  end

  add_index "users", ["email"], :name => "index_users_on_email", :unique => true
  add_index "users", ["reset_password_token"], :name => "index_users_on_reset_password_token", :unique => true

end
