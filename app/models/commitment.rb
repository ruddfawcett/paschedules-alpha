# == Schema Information
#
# Table name: commitments
#
#  id           :integer          not null, primary key
#  teacher_name :string(255)
#  name         :string(255)
#  title        :string(255)
#  created_at   :datetime
#  updated_at   :datetime
#

class Commitment < ActiveRecord::Base
  has_many :students_commitments, class_name: StudentsCommitments, dependent: :destroy
  has_many :students, through: :students_commitments
end
