class SessionsController < ApplicationController
  def new
  end

  def create
    puts "PARAMS: #{params.inspect}" # Debug output to check params
    user = User.find_by(email: params[:session][:email].downcase)
    puts "USER: #{user.inspect}" if user # Debug output to check if user is found
    if user && user.authenticate(params[:session][:password])
      puts "PASSWORD: AUTHENTICATED" # Debug output to confirm password authentication
      log_in user
      logger.debug "[SessionsController#create] After log_in: session[:user_id] = #{session[:user_id]}"
      logger.debug "[SessionsController#create] After log_in: cookies.signed[:user_id] = #{cookies.signed[:user_id]}"
      puts "SESSION USER_ID: #{session[:user_id]}" # Debug output to check if session is set
      if params[:session][:remember_me] == "1"
        remember(user)
        logger.debug "[SessionsController#create] After remember: cookies.signed[:user_id] = #{cookies.signed[:user_id]}"
        puts "REMEMBER ME: Enabled" # Debug output for remember me
      else
        forget(user)
        logger.debug "[SessionsController#create] After forget: cookies.signed[:user_id] = #{cookies.signed[:user_id]}"
        puts "REMEMBER ME: Disabled" # Debug output for remember me
      end
      redirect_to root_path, notice: "Signed in successfully."
    else
      puts "AUTH FAILED: User #{user ? 'found' : 'not found'}, Password #{user && user.authenticate(params[:session][:password]) ? 'correct' : 'incorrect'}"
      flash.now[:alert] = "Invalid email/password combination"
      render :new
    end
  end

  def destroy
    log_out if logged_in?
    redirect_to root_path, notice: "Signed out successfully."
  end
end
