class CommentsController < ApplicationController
  before_action :set_product
  before_action :set_comment, only: [ :show, :edit, :update, :destroy, :helpful_vote ]
  before_action :authenticate_user!, only: [ :create, :edit, :update, :destroy, :helpful_vote ]

  def create
    comment_attributes = comment_params
    comment_attributes[:user_id] = current_user.id
    comment_attributes[:parent_comment_id] = params[:comment][:parent_comment_id] if params[:comment][:parent_comment_id].present?

    @comment = @product.comments.build(comment_attributes)

    if @comment.save
      redirect_to @product, notice: "Comment was successfully created."
    else
      @comments = @product.comments.includes(:replies)
      flash.now[:alert] = "There was an error submitting your comment."
      render "products/show"
    end
  end

  def show
    # Show action will use @comment set by set_comment
  end

  def new
    @comment = @product.comments.new
    @parent_comment = Comment.find_by(id: params[:parent_comment_id])
  end

  def helpful_vote
    # Check if user has already voted on this comment
    vote = @comment.votes.find_by(user_id: current_user.id)

    if vote
      # User has already voted, so remove the vote
      vote.destroy
      @comment.decrement!(:helpful_vote)
      notice_message = "Your vote has been removed."
    else
      # User hasn't voted yet, so add a vote
      @comment.votes.create(user_id: current_user.id)
      @comment.increment!(:helpful_vote)
      notice_message = "You voted this comment as helpful."
    end

    respond_to do |format|
      format.html { redirect_to @product, notice: notice_message }
      format.json {
        render json: {
          helpful_vote: @comment.helpful_vote,
          voted: @comment.voted_by?(current_user)
        }
      }
    end
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
    params.require(:comment).permit(:content, :parent_comment_id)
  end

  def authenticate_user!
    unless current_user
      redirect_to sign_in_path, alert: "Please sign in to perform this action."
    end
  end
end
