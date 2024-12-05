class SessionsController < ApplicationController
  def new
  end

  def create
    user = User.find_by(email: params[:email])
    if user&.authenticate(params[:password])
      session[:user_id] = user.id
      if user.admin?
        redirect_to root_path, notice: "Signed in as admin!"
      else
        redirect_to root_path, notice: "Signed in successfully!"
      end
    else
      flash.now[:alert] = "Invalid email or password"
      render :new
    end
  rescue BCrypt::Errors::InvalidHash
    redirect_to sign_in_path, alert: "Invalid email or password"
  end

  def destroy
    session[:user_id] = nil
    redirect_to root_path, notice: "Signed out successfully!"
  end
end
