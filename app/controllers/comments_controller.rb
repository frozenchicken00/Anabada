class CommentsController < ApplicationController
  before_action :set_product
  before_action :set_comment, only: [ :edit, :update, :destroy, :helpful_vote ]

  def create
    @comment = @product.comments.build(comment_params)
    @comment.parent_comment_id = params[:comment][:parent_comment_id] if params[:comment][:parent_comment_id].present?
    Rails.logger.debug("parent_comment_id: #{params[:comment][:parent_comment_id]}") # Debugging line
    if @comment.save
      redirect_to @product, notice: "Comment was successfully created."
    else
      @comments = @product.comments.includes(:replies)
      flash.now[:alert] = "There was an error submitting your comment."
      render "products/show"
    end
  end

  def new
    @comment = @product.comments.new
    @parent_comment = Comment.find_by(id: params[:parent_comment_id])
  end

  def helpful_vote
    Rails.logger.debug("Voting on comment ID: #{@comment.id}")
    @comment.increment!(:helpful_vote)  # Increase helpful vote count by 1
    redirect_to @product, notice: "You voted this comment as helpful."
  end

  def edit
    # Edit action logic
  end

  def update
    if @comment.update(comment_params)
      redirect_to @product, notice: "Comment was successfully updated."
    else
      render :edit
    end
  end

  def destroy
    @comment.destroy
    redirect_to @product, notice: "Comment was successfully deleted."
  end

  private

  def set_product
    @product = Product.find(params[:product_id])
  end

  def set_comment
    @comment = @product.comments.find(params[:id])
  end

  def comment_params
    params.require(:comment).permit(:content, :helpful_vote, :parent_comment_id)
  end
end
