class MessagesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_conversation

  def create
    @message = @conversation.messages.new(message_params)
    @message.user = current_user

    if @message.save
      # The broadcast will be handled by the model callback
      # This is for traditional form submission (non-AJAX)
      redirect_to conversation_path(@conversation)
    else
      @messages = @conversation.messages.order(created_at: :asc)
      render "conversations/show"
    end
  end

  # AJAX version for real-time messaging
  def create_ajax
    @message = @conversation.messages.new(message_params)
    @message.user = current_user

    if @message.save
      # Return JSON for API calls
      render json: {
        status: "success",
        message_id: @message.id,
        body: @message.body,
        user_id: @message.user_id,
        timestamp: @message.created_at.strftime("%H:%M")
      }
    else
      render json: { status: "error", errors: @message.errors.full_messages }, status: :unprocessable_entity
    end
  end

  # Mark messages as read
  def mark_as_read
    @conversation.messages.where.not(user_id: current_user.id).unread.update_all(read: true)

    # For AJAX requests
    respond_to do |format|
      format.html { redirect_to conversation_path(@conversation) }
      format.json { render json: { status: "success", unread_count: 0 } }
    end
  end

  private

  def set_conversation
    @conversation = Conversation.find(params[:conversation_id])

    # Check that current user is part of the conversation
    unless @conversation.sender_id == current_user.id || @conversation.receiver_id == current_user.id
      redirect_to conversations_path, alert: "You don't have access to this conversation"
    end
  end

  def message_params
    params.require(:message).permit(:body)
  end

  def authenticate_user!
    unless current_user
      redirect_to sign_in_path, alert: "Please sign in to send messages"
    end
  end
end
