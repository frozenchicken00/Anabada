class MessageBroadcastJob < ApplicationJob
  queue_as :default

  def perform(message)
    # Skip broadcasting if the message is already broadcast by the channel
    return if message.created_at < 1.minute.ago

    conversation = message.conversation
    sender = message.user

    # Broadcast to all participants in the conversation
    conversation.users.each do |user|
      is_current_user = user.id == sender.id

      rendered_message = ApplicationController.renderer.render(
        partial: "messages/message",
        locals: {
          message: message,
          is_current_user: is_current_user
        }
      )

      ConversationChannel.broadcast_to(
        conversation,
        {
          message: message.as_json(include: :user),
          message_html: rendered_message,
          for_user_id: user.id
        }
      )
    end
  end
end
