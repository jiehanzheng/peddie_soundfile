module SessionsHelper

  def current_user=(user)
    unless user.nil?
      session[:user_id] = user.id
      @current_user = user
    else
      session[:user_id] = nil
    end
  end

  def current_user
    @current_user ||= User.find_by(id: session[:user_id]) if session[:user_id]
  end

  def require_login
    if !current_user
      flash[:warning] = "Please " + view_context.link_to("sign in", signin_path(request.original_url), :class => "alert-link") + " to view that page."
      redirect_to root_path
    end
  end

  private

    def signin_path(origin)
      if origin.blank?
        "/auth/google_oauth2"
      else
        "/auth/google_oauth2?" + { :origin => origin }.to_query
      end
    end

end
