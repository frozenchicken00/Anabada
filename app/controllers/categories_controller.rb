class CategoriesController < ApplicationController
  before_action :authenticate_admin!
  before_action :set_category, only: [ :edit, :update, :destroy ]
  def new
    @category = Category.new
  end

  def index
    @categories = Category.all
  end

  def create
    @category = Category.new(category_params)
    if @category.save
      redirect_to products_path, notice: "Category was successfully created."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    # @category is set by the set_category method
  end

  def update
    if @category.update(category_params)
      redirect_to products_path, notice: "Category was successfully updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @category.destroy
    redirect_to categories_path, notice: "Category was successfully deleted."
  end

  private

  def set_category
    @category = Category.find(params[:id])
  end

  def category_params
    params.require(:category).permit(:name)
  end

  def authenticate_admin!
    unless admin?
      redirect_to root_path, alert: "You are not authorized to access this page."
    end
  end
end
