class ConversationChannel < ApplicationCable::Channel
  def subscribed
    return reject unless current_user

    @conversation = Conversation.find_by(id: params[:conversation_id])

    if @conversation && @conversation.participates?(current_user)
      stream_for @conversation
    else
      reject
    end
  end

  def unsubscribed
    # Any cleanup needed when channel is unsubscribed
  end

  def send_message(data)
    return unless @conversation && current_user

    message = @conversation.messages.create(
      body: data["body"],
      user: current_user
    )

    if message.persisted?
      rendered_message = ApplicationController.renderer.render(
        partial: "messages/message",
        locals: {
          message: message,
          is_current_user: true
        }
      )

      # Broadcast to current user
      ConversationChannel.broadcast_to(@conversation, {
        message: message.as_json(include: :user),
        message_html: rendered_message
      })

      # Broadcast to the other user with different partial
      rendered_message_for_other = ApplicationController.renderer.render(
        partial: "messages/message",
        locals: {
          message: message,
          is_current_user: false
        }
      )

      # Mark as unread for other participants
      @conversation.mark_as_unread_for_others(current_user)

      # Broadcast to other participants
      @conversation.users.where.not(id: current_user.id).each do |user|
        ConversationChannel.broadcast_to(
          @conversation,
          {
            message: message.as_json(include: :user),
            message_html: rendered_message_for_other,
            for_user_id: user.id
          }
        )
      end
    end
  end
end
