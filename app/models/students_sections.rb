# == Schema Information
#
# Table name: students_sections
#
#  id         :integer          not null, primary key
#  student_id :integer          not null
#  section_id :integer          not null
#

class StudentsSections < ActiveRecord::Base
  belongs_to :student
  belongs_to :section
end
