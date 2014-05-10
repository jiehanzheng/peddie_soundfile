class Course < ActiveRecord::Base
  has_many :assignments
  has_many :enrollments
  has_many :users, through: :enrollments
  has_many :student_enrollments, -> { student }, class_name: 'Enrollment'
  has_many :students, class_name: 'User', through: :student_enrollments, source: :user
  has_many :teacher_enrollments, -> { teacher }, class_name: 'Enrollment'
  has_many :teachers, class_name: 'User', through: :teacher_enrollments, source: :user

  validates :name, presence: true

  after_commit :associate_students_on_email_list!


  # Read students' email addresses from a list (one address per line), and 
  # attach the student to this course if he/she has registered with this site.
  def associate_students_on_email_list!
    student_emails = email_list.split

    User.where(email: student_emails).each do |student|
      students << student
    end
  end

end
