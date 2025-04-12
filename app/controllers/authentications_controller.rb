class AuthenticationsController < ApplicationController
  def create
    @user = User.where(uid: user_hash[:uid], provider: user_hash[:provider]).first
    if @user
      log_in @user
      redirect_to root_path, notice: "Signed in successfully"
    else
      @user = User.new_from_hash(user_hash)
      if @user.save
        log_in @user
        redirect_to root_path, notice: "Signed up successfully"
      else
        session[:user_hash] = user_hash
        redirect_to sign_up_path, notice: "Please complete your registration"
      end
    end
  end

  private

  def auth_hash
    request.env["omniauth.auth"]
  end

  def user_hash
    hash = {}
    hash[:uid] = auth_hash[:uid]
    hash[:provider] = auth_hash[:provider]
    if auth_hash["info"]
      hash[:email] = auth_hash["info"]["email"]
      hash[:username] = auth_hash["info"]["name"]
    end
    if auth_hash["credentials"]
      hash[:token] = auth_hash["credentials"]["token"]
    end
    hash
  end
end
