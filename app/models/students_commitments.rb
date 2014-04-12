# == Schema Information
#
# Table name: students_commitments
#
#  id            :integer          not null, primary key
#  student_id    :integer
#  commitment_id :integer
#

class StudentsCommitments < ActiveRecord::Base
  belongs_to :student
  belongs_to :commitment
end
