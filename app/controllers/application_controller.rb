class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  include SessionsHelper


  protected
    def require_login
      if !current_user
        flash[:warning] = "Please " + view_context.link_to("sign in", signin_path(request.original_url), :class => "alert-link") + " to access that page."
        redirect_to root_path
      end
    end

    def require_admin
      unless current_user.admin?
        flash[:error] = "Only admins can access that page."
        redirect_to root_path
      end
    end

    def require_teacher(course)
      unless current_user.in? course.teachers
        flash[:error] = "Only teachers can perform that action."
        redirect_to root_path
      end
    end

    def require_student(course)
      unless current_user.in? course.users
        flash[:error] = "Only students/teachers of this course can perform that action."
        redirect_to root_path
      end
    end

end
