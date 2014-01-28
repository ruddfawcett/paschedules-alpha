class CreateSchema < ActiveRecord::Migration
  def change
    create_table "courses" do |t|
      t.integer  "teacher_id"
      t.string   "name"
      t.timestamps
    end

    create_table "people" do |t|
      t.string   "email"
      t.string   "first_name"
      t.string   "last_name"
      t.string   "full_name"
      t.string   "pref_name"
      t.string   "type"
      t.string   "pa_id"
      t.timestamps
    end

    create_table "sections" do |t|
      t.integer  "course_id"
      t.integer  "section_number"
      t.string   "times"
      t.string   "room"
      t.timestamps
    end

    create_table "students" do |t|
      t.timestamps
    end

    create_table "students_sections" do |t|
      t.integer "student_id", null: false
      t.integer "section_id", null: false
    end

    add_index "students_sections", ["student_id", "section_id"], name: "index_students_sections_on_student_id_and_section_id", using: :btree

    create_table "teachers" do |t|
      t.timestamps
    end
  end
end
