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

ActiveRecord::Schema.define(:version => 20131015120301) do

  create_table "api_keys", :force => true do |t|
    t.string   "token",      :null => false
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
    t.integer  "user_id"
  end

  create_table "identities", :force => true do |t|
    t.string   "type"
    t.string   "api_key"
    t.integer  "user_id"
    t.datetime "created_at",               :null => false
    t.datetime "updated_at",               :null => false
    t.string   "source_id",                :null => false
    t.datetime "last_projects_refresh_at"
  end

  add_index "identities", ["api_key", "type"], :name => "index_identities_on_api_key_and_type", :unique => true

  create_table "participations", :force => true do |t|
    t.integer  "identity_id", :null => false
    t.integer  "project_id",  :null => false
    t.datetime "created_at",  :null => false
    t.datetime "updated_at",  :null => false
  end

  create_table "projects", :force => true do |t|
    t.string   "name",                  :null => false
    t.string   "source_name",           :null => false
    t.string   "source_identifier",     :null => false
    t.datetime "created_at",            :null => false
    t.datetime "updated_at",            :null => false
    t.string   "web_hook"
    t.string   "web_hook_token"
    t.tsvector "tsvector_name_tsearch"
  end

  add_index "projects", ["source_name", "source_identifier"], :name => "index_projects_on_source_name_and_source_identifier", :unique => true

  create_table "tasks", :force => true do |t|
    t.datetime "created_at",                               :null => false
    t.datetime "updated_at",                               :null => false
    t.integer  "project_id",                               :null => false
    t.text     "name",                                     :null => false
    t.string   "source_name",                              :null => false
    t.string   "source_identifier",                        :null => false
    t.string   "current_state",                            :null => false
    t.string   "story_type",                               :null => false
    t.boolean  "current_task",          :default => false
    t.tsvector "tsvector_name_tsearch"
  end

  add_index "tasks", ["source_name", "source_identifier"], :name => "index_tasks_on_source_name_and_source_identifier", :unique => true

  create_table "time_log_entries", :force => true do |t|
    t.integer  "task_id"
    t.integer  "user_id",                       :null => false
    t.boolean  "running",    :default => false
    t.datetime "started_at",                    :null => false
    t.datetime "stopped_at"
    t.integer  "seconds",    :default => 0,     :null => false
    t.datetime "created_at",                    :null => false
    t.datetime "updated_at",                    :null => false
  end

  create_table "users", :force => true do |t|
    t.string   "email"
    t.string   "password_digest"
    t.datetime "created_at",             :null => false
    t.datetime "updated_at",             :null => false
    t.string   "confirmation_token"
    t.string   "password_reset_token"
    t.datetime "password_reset_sent_at"
    t.string   "auth_token"
    t.string   "oauth_token"
    t.datetime "oauth_token_expires_at"
    t.string   "refreshing"
  end

  add_index "users", ["confirmation_token"], :name => "index_users_on_confirmation_token", :unique => true

end
