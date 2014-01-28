# == Schema Information
#
# Table name: sections
#
#  id         :integer          not null, primary key
#  course_id  :integer          not null
#  name       :string(255)
#  times      :string(255)
#  room       :string(255)
#  created_at :datetime
#  updated_at :datetime
#

class Section < ActiveRecord::Base
  belongs_to :course
  has_many :students_sections, dependent: :destroy
  has_many :students, through: :students_sections
end
