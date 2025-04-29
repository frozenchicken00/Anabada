class ConversationChannel < ApplicationCable::Channel
  def subscribed
    logger.debug "ConversationChannel#subscribed: Attempting subscription for user: #{current_user&.id}, conversation_id: #{params[:conversation_id]}"
    return reject unless current_user

    @conversation = Conversation.find_by(id: params[:conversation_id])
    logger.debug "ConversationChannel#subscribed: Found conversation: #{@conversation&.id}"

    if @conversation && @conversation.participates?(current_user)
      stream_for [ @conversation, current_user ]
      logger.debug "ConversationChannel#subscribed: User #{current_user.id} authorized. Streaming for conversation #{@conversation.id} / user #{current_user.id}."
    else
      logger.warn "ConversationChannel#subscribed: User #{current_user.id} REJECTED for conversation #{@conversation&.id}. participates?: #{@conversation&.participates?(current_user)}"
      reject
    end
  end

  def unsubscribed
    # Any cleanup needed when channel is unsubscribed
  end

  def send_message(data)
    logger.debug "ConversationChannel#send_message: Received data from user #{current_user&.id} for conversation #{@conversation&.id}: #{data.inspect}"
    unless @conversation && current_user
      logger.error "ConversationChannel#send_message: Aborting, conversation or current_user missing."
      return
    end

    message = @conversation.messages.create(
      body: data["body"],
      user: current_user
    )

    logger.debug "ConversationChannel#send_message: Message persisted? #{message.persisted?}. Errors: #{message.errors.full_messages.join(', ')}"

    if message.persisted?
      begin
        logger.debug "ConversationChannel#send_message: Rendering message partials for message #{message.id}"

        # Mark as unread for other participants
        @conversation.mark_as_unread_for_others(current_user)

        # Send to the current user (sender)
        rendered_message_for_sender = ApplicationController.renderer.render(
          partial: "messages/message",
          locals: { message: message, is_current_user: true }
        )
        ConversationChannel.broadcast_to(
          [ @conversation, current_user ],
          {
            message: message.as_json(include: :user),
            message_html: rendered_message_for_sender
          }
        )

        # Send to other participants (receivers)
        @conversation.users.where.not(id: current_user.id).each do |user|
          rendered_message_for_receiver = ApplicationController.renderer.render(
            partial: "messages/message",
            locals: { message: message, is_current_user: false }
          )
          ConversationChannel.broadcast_to(
            [ @conversation, user ],
            {
              message: message.as_json(include: :user),
              message_html: rendered_message_for_receiver
            }
          )
        end

        logger.debug "ConversationChannel#send_message: Broadcasting complete for message #{message.id}."
      rescue => e
        logger.error "ConversationChannel#send_message: ERROR during rendering/broadcasting: #{e.message}\n#{e.backtrace.join("\n")}"
      end
    else
      logger.error "ConversationChannel#send_message: Failed to save message for user #{current_user.id}. Body: #{data['body']}"
    end
  end
end
