class Enrollment < ActiveRecord::Base
  belongs_to :course
  belongs_to :user

  enum user_role: [ :student, :teacher ]

end
