class ProductsController < ApplicationController
  before_action :set_product, only: %i[ show edit update destroy ]
  before_action :authenticate_user!, except: %i[ index show ]
  before_action :authorize_product!, only: %i[ edit update destroy ]

  # GET /products or /products.json
  def index
    if params[:query].present?
      @products = Product.search(params[:query],
        fields: [ :name, :description, :category_name ],
        match: :word_start,
        misspellings: { below: 5 }
      )
    elsif params[:category_id].presence
      @category = Category.find_by(id: params[:category_id])
      @products = @category ? @category.products : Product.all
    else
      @products = Product.all
    end
  end


  # GET /products/1 or /products/1.json
  def show
    @product = Product.find(params[:id])
    @comments = @product.comments.where(parent_comment_id: nil).order(helpful_vote: :desc)
    @comment = Comment.new
    @other_products = Product.where.not(id: @product.id).limit(3)
  end

  # GET /products/new
  def new
    @product = Product.new
  end

  # GET /products/1/edit
  def edit
  end

  # POST /products or /products.json
  def create
    @product = current_user.products.build(product_params)

    respond_to do |format|
      begin
        if @product.save
          format.html { redirect_to @product, notice: "Product was successfully created." }
          format.json { render :show, status: :created, location: @product }
        else
          format.html { render :new, status: :unprocessable_entity }
          format.json { render json: @product.errors, status: :unprocessable_entity }
        end
      rescue => e
        Rails.logger.error("ERROR: #{e.class}: #{e.message}\n#{e.backtrace.join("\n")}")
        format.html { redirect_to new_product_path, alert: "Error creating product. Please try again." }
        format.json { render json: { error: e.message }, status: :internal_server_error }
      end
    end
  end

  # PATCH/PUT /products/1 or /products/1.json
  def update
    respond_to do |format|
      if @product.update(product_params)
        format.html { redirect_to @product, notice: "Product was successfully updated." }
        format.json { render :show, status: :ok, location: @product }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @product.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /products/1 or /products/1.json
  def destroy
    @product.destroy!

    respond_to do |format|
      format.html { redirect_to products_path, status: :see_other, notice: "Product was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_product
      @product = Product.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def product_params
      params.require(:product).permit(:name, :description, :posted_date, :price, :category_id, pictures: [])
    end

    def authorize_product!
      unless @product.user == current_user
        redirect_to products_path, alert: "You are not authorized to perform this action."
      end
    end
end
