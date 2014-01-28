class SetNotNull < ActiveRecord::Migration
  def change
    change_column :courses, :teacher_id, :integer, null: false
    change_column :sections, :course_id, :integer, null: false
  end
end
