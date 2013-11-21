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

ActiveRecord::Schema.define(version: 20131120213215) do

  create_table "annotations", force: true do |t|
    t.integer  "response_id"
    t.integer  "audio_file_id"
    t.float    "start_second"
    t.float    "end_second"
    t.text     "notes"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "audio_files", force: true do |t|
    t.string   "wav_name"
    t.string   "ogg_name"
    t.string   "path"
    t.integer  "convert_tries"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "responses", force: true do |t|
    t.integer  "assignment_id"
    t.integer  "user_id"
    t.integer  "audio_file_id"
    t.text     "notes"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

end
