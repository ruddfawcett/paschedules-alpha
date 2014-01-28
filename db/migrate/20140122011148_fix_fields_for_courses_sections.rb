class FixFieldsForCoursesSections < ActiveRecord::Migration
  def change
    rename_column :sections, :section_number, :name
    add_column :courses, :title, :string
  end
end
