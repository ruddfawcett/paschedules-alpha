# == Schema Information
#
# Table name: people
#
#  id         :integer          not null, primary key
#  email      :string(255)
#  first_name :string(255)
#  last_name  :string(255)
#  full_name  :string(255)
#  pref_name  :string(255)
#  type       :string(255)
#  pa_id      :string(255)
#  created_at :datetime
#  updated_at :datetime
#  cluster    :string(255)
#  grad_year  :string(255)
#  department :string(255)
#  unexcused  :integer
#

class Student < Person
  has_many :students_sections, class_name: StudentsSections, dependent: :destroy
  has_many :sections, through: :students_sections

  has_many :students_commitments, class_name: StudentsCommitments, dependent: :destroy
  has_many :commitments, through: :students_commitments
end
