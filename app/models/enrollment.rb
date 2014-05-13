class Enrollment < ActiveRecord::Base
  belongs_to :course
  belongs_to :user

  validates_uniqueness_of :user_id, scope: [:course_id, :user_role]

  enum user_role: [:student, :teacher]

end
