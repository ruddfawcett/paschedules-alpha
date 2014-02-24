class Commitment < ActiveRecord::Base
  has_many :students_commitments, dependent: :destroy
  has_many :students, through: :students_commitments
end
