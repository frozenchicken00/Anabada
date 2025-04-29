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
    # Ensure the cookie Action Cable uses is always set on login
    cookies.signed[:user_id] = { value: user.id, httponly: true, same_site: :lax }
    logger.debug "[ApplicationController#log_in] Set session[:user_id] = #{session[:user_id]}"
    logger.debug "[ApplicationController#log_in] Set cookies.signed[:user_id] = #{cookies.signed[:user_id]}"
  end

  # Remembers a user in a persistent session.
  def remember(user)
    user.remember # Generate and store digest in DB
    # Use permanent cookies for long-term persistence if remember_me is checked
    cookies.permanent.signed[:user_id] = { value: user.id, httponly: true, same_site: :lax }
    cookies.permanent[:remember_token] = { value: user.remember_token, httponly: true, same_site: :lax }
    logger.debug "[ApplicationController#remember] Set permanent cookies.signed[:user_id] = #{cookies.signed[:user_id]}"
    logger.debug "[ApplicationController#remember] Set permanent cookies[:remember_token] = #{cookies[:remember_token]}"
  end

  # Forgets a persistent session.
  def forget(user)
    user.forget # Clear remember digest in DB
    # Only delete the remember_token, not the main user_id cookie
    cookies.delete(:remember_token)
    logger.debug "[ApplicationController#forget] Deleted cookies[:remember_token] for user #{user&.id}"
  end

  # Logs out the current user.
  def log_out
    forget(current_user)
    session.delete(:user_id)
    # Explicitly delete the cookie Action Cable uses
    cookies.delete(:user_id)
    logger.debug "[ApplicationController#log_out] Deleted session and cookies[:user_id]"
    @current_user = nil
  end

  # Returns true if the user is logged in, false otherwise.
  def logged_in?
    !current_user.nil?
  end
end
