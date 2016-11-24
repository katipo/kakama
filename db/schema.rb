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
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20161110190820) do

  create_table "availabilities", :force => true do |t|
    t.integer  "staff_id",     :null => false
    t.date     "start_date",   :null => false
    t.date     "end_date",     :null => false
    t.text     "hours",        :null => false
    t.boolean  "admin_locked"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "availabilities", ["end_date"], :name => "index_availabilities_on_end_date"
  add_index "availabilities", ["staff_id"], :name => "index_availabilities_on_staff_id"
  add_index "availabilities", ["start_date"], :name => "index_availabilities_on_start_date"

  create_table "delayed_jobs", :force => true do |t|
    t.integer  "priority",   :default => 0
    t.integer  "attempts",   :default => 0
    t.text     "handler"
    t.text     "last_error"
    t.datetime "run_at"
    t.datetime "locked_at"
    t.datetime "failed_at"
    t.string   "locked_by"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "detail_types", :force => true do |t|
    t.string   "name",       :null => false
    t.string   "field_type", :null => false
    t.datetime "deleted_at"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "detail_types", ["name"], :name => "index_detail_types_on_name", :unique => true

  create_table "email_logs", :force => true do |t|
    t.string   "email_type", :null => false
    t.string   "subject",    :null => false
    t.integer  "staff_id",   :null => false
    t.integer  "event_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "email_logs", ["staff_id", "event_id"], :name => "index_email_logs_on_staff_id_and_event_id"

  create_table "events", :force => true do |t|
    t.integer  "venue_id",       :null => false
    t.boolean  "recurring"
    t.integer  "schedule_id",    :null => false
    t.string   "name",           :null => false
    t.text     "description"
    t.datetime "start_datetime", :null => false
    t.datetime "end_datetime",   :null => false
    t.integer  "organiser_id",   :null => false
    t.string   "state",          :null => false
    t.text     "roles"
    t.datetime "deleted_at"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "approver_id"
  end

  add_index "events", ["deleted_at"], :name => "index_events_on_deleted_at"
  add_index "events", ["end_datetime"], :name => "index_events_on_end_datetime"
  add_index "events", ["organiser_id"], :name => "index_events_on_organiser_id"
  add_index "events", ["schedule_id"], :name => "index_events_on_schedule_id"
  add_index "events", ["start_datetime"], :name => "index_events_on_start_datetime"
  add_index "events", ["venue_id"], :name => "index_events_on_venue_id"

  create_table "roles", :force => true do |t|
    t.string   "name",        :null => false
    t.string   "description"
    t.datetime "deleted_at"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "roles", ["name"], :name => "index_roles_on_name", :unique => true

  create_table "rosterings", :force => true do |t|
    t.integer  "staff_id",       :null => false
    t.integer  "event_id",       :null => false
    t.integer  "role_id",        :null => false
    t.string   "state",          :null => false
    t.boolean  "system_flagged"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "rosterings", ["event_id"], :name => "index_rosterings_on_event_id"
  add_index "rosterings", ["role_id"], :name => "index_rosterings_on_role_id"
  add_index "rosterings", ["staff_id"], :name => "index_rosterings_on_staff_id"

  create_table "schedules", :force => true do |t|
    t.string   "name",       :null => false
    t.integer  "interval",   :null => false
    t.string   "delay",      :null => false
    t.datetime "deleted_at"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "staff_details", :force => true do |t|
    t.integer  "staff_id",       :null => false
    t.integer  "detail_type_id", :null => false
    t.text     "value",          :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "staff_details", ["detail_type_id"], :name => "index_staff_details_on_detail_type_id"
  add_index "staff_details", ["staff_id"], :name => "index_staff_details_on_staff_id"

  create_table "staff_roles", :force => true do |t|
    t.integer  "staff_id",   :null => false
    t.integer  "role_id",    :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "staff_roles", ["staff_id", "role_id"], :name => "index_staff_roles_on_staff_id_and_role_id"

  create_table "staffs", :force => true do |t|
    t.string   "username",                            :null => false
    t.string   "staff_type",                          :null => false
    t.string   "crypted_password",                    :null => false
    t.string   "email"
    t.string   "full_name",                           :null => false
    t.date     "start_date",                          :null => false
    t.text     "admin_notes"
    t.datetime "deleted_at"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "password_salt",                       :null => false
    t.string   "persistence_token",                   :null => false
    t.string   "perishable_token",                    :null => false
    t.datetime "last_request_at"
    t.string   "single_access_token", :default => "", :null => false
  end

  add_index "staffs", ["full_name"], :name => "index_staffs_on_full_name"
  add_index "staffs", ["start_date"], :name => "index_staffs_on_start_date"
  add_index "staffs", ["username"], :name => "index_staffs_on_username"

  create_table "venues", :force => true do |t|
    t.string   "name",        :null => false
    t.text     "description"
    t.datetime "deleted_at"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "venues", ["deleted_at"], :name => "index_venues_on_deleted_at"
  add_index "venues", ["name"], :name => "index_venues_on_name", :unique => true

end
