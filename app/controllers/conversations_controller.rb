class ConversationsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_conversation, only: [ :show, :destroy ] # Add :destroy

  def index
    # Get all conversations involving the current user
    @conversations = current_user.conversations.includes(:sender, :receiver)

    # New conversation form
    @users = User.where.not(id: current_user.id)
    @conversation = Conversation.new
  end

  def show
    # Set up for displaying the conversation
    @messages = @conversation.messages.includes(:user).order(created_at: :asc)
    @message = Message.new

    # Mark unread messages as read when viewing the conversation
    @conversation.messages.where.not(user_id: current_user.id).unread.update_all(read: true)

    # The other user in the conversation
    @other_user = @conversation.other_user(current_user)

    respond_to do |format|
      format.html
      format.js
    end
  end

  def create
    # Check if receiver is selected
    if params[:receiver_id].blank?
      return redirect_to conversations_path, alert: "Please select a user to message"
    end

    # Find the receiver
    receiver = User.find(params[:receiver_id])

    # Check if conversation already exists
    conversation = Conversation.between(current_user.id, receiver.id).first

    # If no existing conversation, create one
    if conversation.nil?
      conversation = Conversation.create(sender: current_user, receiver: receiver)
    end

    # Redirect to the conversation
    redirect_to conversation_path(conversation)
  end

  def destroy
    # Make sure all messages are deleted first
    @conversation.messages.destroy_all

    if @conversation.destroy
      redirect_to conversations_path, notice: "Conversation deleted successfully."
    else
      redirect_to @conversation, alert: "Unable to delete conversation."
    end
  end

  private

  def set_conversation
    @conversation = Conversation.find(params[:id])

    # Make sure the current user is part of this conversation
    unless @conversation.sender_id == current_user.id || @conversation.receiver_id == current_user.id
      redirect_to conversations_path, alert: "You don't have access to this conversation"
    end
  end

  def conversation_params
    params.require(:conversation).permit(:receiver_id)
  end

  def authenticate_user!
    unless current_user
      redirect_to sign_in_path, alert: "Please sign in to access messages"
    end
  end
end
