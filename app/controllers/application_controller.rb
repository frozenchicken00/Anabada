class ApplicationController < ActionController::Base
  # allow_browser versions: :modern

  helper_method :current_user, :admin?

  def current_user
    @current_user ||= User.find(session[:user_id]) if session[:user_id]
  end

  def admin?
    current_user&.admin
  end

  def authenticate_user!
    redirect_to sign_in_path, alert: "You need to sign in first" unless current_user
  end

  def authenticate_admin!
    redirect_to root_path, alert: "You are not authorized to access this page" unless admin?
  end

  def login(user)
    session[:user_id] = user.id
  end
end
