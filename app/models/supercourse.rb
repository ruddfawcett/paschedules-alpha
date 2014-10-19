# == Schema Information
#
# Table name: supercourses
#
#  id         :integer          not null, primary key
#  name       :string(255)
#  title      :string(255)
#  created_at :datetime
#  updated_at :datetime
#

class Supercourse < ActiveRecord::Base
  has_many :courses
end
