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

require 'test_helper'

class CourseTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
