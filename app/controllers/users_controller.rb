class UsersController < ApplicationController
  before_action :authenticate_user!, except: [ :new, :new_admin, :create ]
  before_action :set_user, only: [ :show, :edit, :update, :destroy ]
  before_action :authorize_user!, only: [ :edit, :update, :destroy ]

  def show
    # Profile page
    @products = @user.products.includes(:category).order(created_at: :desc)
  end

  def new
    if session[:user_hash]
      @user = User.new_from_hash session[:user_hash]
      @user.valid?
    end
    @user = User.new
  end

  def new_admin
    @user = User.new
  end

  def edit
    @user = current_user
  end

  def create
    if session[:user_hash]
      @user = User.new_from_hash session[:user_hash]
      @user.name = user_params[:username]
      @user.email = user_params[:email]
    else
      @user = User.new user_params
    end
    # @user = User.new(user_params)
    if @user.save
      session[:user_id] = @user.id
      session[:user_hash] = nil
      redirect_to root_path, notice: "Sign up successful!"
    else
      render params[:admin] ? :new_admin : :new
    end
  end

  def update
    @user = current_user
    if params[:user][:password].present?
      # Verify old password before updating
      if @user.authenticate(params[:user][:current_password])
        if @user.update(user_params)
          redirect_to @user, notice: "Profile was successfully updated."
        else
          render :edit
        end
      else
        @user.errors.add(:current_password, "is incorrect")
        render :edit
      end
    else
      # Updating without changing password
      if @user.update(user_params_without_password)
        redirect_to @user, notice: "Profile was successfully updated."
      else
        render :edit
      end
    end
  end

  def destroy
    @user = current_user
    if @user.has_password?
      if @user.authenticate(params[:user][:current_password])
        @user.destroy
        session[:user_id] = nil  # Log out the user
        redirect_to root_path, notice: "Your account has been deleted."
      else
        redirect_to edit_user_path(@user), alert: "Current password is incorrect."
      end
    else
      @user.destroy
      reset_session  # Log out the user
      redirect_to root_path, notice: "Your account has been deleted."
    end
  end

  private

  def set_user
    @user = User.find(params[:id])
  end

  def authorize_user!
    unless @user == current_user
      redirect_to root_path, alert: "You are not authorized to perform this action."
    end
  end

  def user_params
    params.require(:user).permit(:username, :email, :password, :password_confirmation, :admin)
  end

  def user_params_without_password
    params.require(:user).permit(:username, :email)
  end
end
