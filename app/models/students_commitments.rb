class StudentsCommitments < ActiveRecord::Base
  belongs_to :student
  belongs_to :commitment
end
