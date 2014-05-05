class User < ActiveRecord::Base
  has_many :enrollments
  has_many :courses, through: :enrollments


  def self.from_auth_hash(auth_hash)
    auth_hash = auth_hash.with_indifferent_access

    user = where(auth_hash.slice("provider", "uid")).first || create_from_auth_hash(auth_hash)

    begin
      update_user_with_auth_hash(auth_hash, user)
      user.save!
    rescue => detail
      raise "We are unable to save your information to user table: " + detail.message
    end

    user
  end

  def self.create_from_auth_hash(auth_hash)
    create! do |user|
      user.provider = auth_hash[:provider]
      user.uid = auth_hash[:uid]

      if user.provider == 'google_oauth2' && !is_peddie_email(auth_hash[:info][:email])
        raise "You have to sign in with a valid Peddie School email address."
      end

      update_user_with_auth_hash(auth_hash, user)
    end
  end

  def self.is_peddie_email(email_address)
    if email_address =~ /\A(?:[a-z\-]+)(?:-(\d{2}))?@peddie\.org\z/
      true
    else
      false
    end
  end

  def graduation_year
    if email =~ /\A(?:[a-z\-]+)(?:-(\d{2}))?@peddie\.org\z/
      $1.to_i
    else
      nil
    end
  end

  def full_name
    "#{first_name} #{last_name}"
  end

  def is_student?
    graduation_year != nil
  end

  def teacher_of?(course)
    in? course.teachers
  end

  def student_of?(course)
    in? course.users
  end
  

  private

    def self.update_user_with_auth_hash(auth_hash, user)
      if auth_hash[:provider] != 'google_oauth2'
        return
      end

      user.first_name = auth_hash[:info][:first_name]
      user.last_name  = auth_hash[:info][:last_name]
      user.email      = auth_hash[:info][:email]
    end

    # Find courses of which the student is already a member, and enroll
    # automatically.
    def auto_enroll
      Course.all.each do |course|
        course.associate_students_on_email_list!
      end
    end

end
