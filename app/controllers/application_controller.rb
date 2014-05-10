class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  include SessionsHelper


  protected
    def require_login
      unless current_user
        flash[:warning] = "Please " + view_context.link_to("sign in", signin_path(request.original_url), :class => "alert-link") + " to access that page."
        redirect_to root_path
        return false
      end

      true
    end

    def require_admin
      unless current_user.admin?
        flash[:error] = "Only admins can access that page."
        redirect_to root_path
        return false
      end

      true
    end

    def require_teacher(course)
      unless current_user.teacher_of? course
        flash[:error] = "Only teachers can perform that action."
        redirect_to root_path
        return false
      end

      true
    end

    def require_student(course)
      unless current_user.student_of? course
        flash[:error] = "Only students/teachers of this course can perform that action."
        redirect_to root_path
        return false
      end

      true
    end

    def require_same_user_or_teacher(user, course)
      unless current_user == user || current_user.teacher_of?(course)
        flash[:error] = "Only " + user.full_name + " can perform that action."
        redirect_to root_path
        return false
      end

      true
    end

end
