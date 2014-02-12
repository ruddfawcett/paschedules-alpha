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

ActiveRecord::Schema.define(version: 20140123213000) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "courses", force: true do |t|
    t.integer  "teacher_id", null: false
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "title"
  end

  create_table "people", force: true do |t|
    t.string   "email"
    t.string   "first_name"
    t.string   "last_name"
    t.string   "full_name"
    t.string   "pref_name"
    t.string   "type"           # For STI
    t.string   "pa_id"          # This is the student ID number, not a reference to another model
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "cluster"
    t.string   "grad_year"
  end

  create_table "sections", force: true do |t|
    t.integer  "course_id",  null: false
    t.string   "name"
    t.string   "times"
    t.string   "room"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "students_sections", force: true do |t|
    t.integer "student_id", null: false
    t.integer "section_id", null: false
  end

  add_index "students_sections", ["student_id", "section_id"], name: "index_students_sections_on_student_id_and_section_id", using: :btree

end
