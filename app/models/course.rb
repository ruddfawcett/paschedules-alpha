# == Schema Information
#
# Table name: courses
#
#  id         :integer          not null, primary key
#  teacher_id :integer          not null
#  name       :string(255)
#  created_at :datetime
#  updated_at :datetime
#  title      :string(255)
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
