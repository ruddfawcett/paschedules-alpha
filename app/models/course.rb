# == Schema Information
#
# Table name: courses
#
#  id             :integer          not null, primary key
#  teacher_id     :integer          not null
#  created_at     :datetime
#  updated_at     :datetime
#  supercourse_id :integer
#

class Course < ActiveRecord::Base
  has_many :sections
  belongs_to :teacher
  belongs_to :supercourse

  # Helper methods to make the old code not crash
  def name
    supercourse.name
  end

  def title
    supercourse.title
  end
end
