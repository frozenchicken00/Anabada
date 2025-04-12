class ApplicationController < ActionController::Base
  # allow_browser versions: :modern

  helper_method :current_user, :admin?, :logged_in?

  def current_user
    if (user_id = session[:user_id]) # Check session first
      @current_user ||= User.find_by(id: user_id)
    elsif (user_id = cookies.signed[:user_id]) # Check remember me cookie
      user = User.find_by(id: user_id)
      # Use the authenticated? method from the User model
      if user && user.authenticated?(:remember, cookies[:remember_token])
        log_in user # Log the user in via session now
        @current_user = user
      end
    end
  end

  def admin?
    current_user&.admin
  end

  def authenticate_user!
    redirect_to sign_in_path, alert: "You need to sign in first" unless logged_in?
  end

  def authenticate_admin!
    redirect_to root_path, alert: "You are not authorized to access this page" unless admin?
  end

  # Logs in the given user.
  def log_in(user)
    session[:user_id] = user.id
  end

  # Remembers a user in a persistent session.
  def remember(user)
    user.remember # Generate and store digest in DB
    cookies.permanent.signed[:user_id] = user.id
    cookies.permanent[:remember_token] = user.remember_token # Store raw token
  end

  # Forgets a persistent session.
  def forget(user)
    user.forget # Clear digest in DB
    cookies.delete(:user_id)
    cookies.delete(:remember_token)
  end

  # Logs out the current user.
  def log_out
    forget(current_user)
    session.delete(:user_id)
    @current_user = nil
  end

  # Returns true if the user is logged in, false otherwise.
  def logged_in?
    !current_user.nil?
  end
end
