class Conversation < ApplicationRecord
  belongs_to :sender, class_name: "User", foreign_key: "sender_id"
  belongs_to :receiver, class_name: "User", foreign_key: "receiver_id"

  has_many :messages, dependent: :destroy

  validates_uniqueness_of :sender_id, scope: :receiver_id

  # Scope to find conversations for a specific user
  scope :between, ->(sender_id, receiver_id) do
    where("(conversations.sender_id = ? AND conversations.receiver_id = ?) OR
           (conversations.sender_id = ? AND conversations.receiver_id = ?)",
           sender_id, receiver_id, receiver_id, sender_id)
  end

  # Scope to find all conversations where a user is involved
  scope :involving, ->(user_id) do
    where("conversations.sender_id = ? OR conversations.receiver_id = ?", user_id, user_id)
  end

  # Get the most recent message in this conversation
  def last_message
    messages.order(created_at: :desc).first
  end

  # Check if the conversation has unread messages for a user
  def unread_messages_for?(user)
    messages.where(read: false).where.not(user: user).exists?
  end

  # Count of unread messages for a user
  def unread_count_for(user)
    messages.where(read: false).where.not(user: user).count
  end

  # Other participant (not the current user)
  def other_user(current_user)
    sender_id == current_user.id ? receiver : sender
  end

  # Check if a user is a participant in this conversation
  def participates?(user)
    sender_id == user.id || receiver_id == user.id
  end

  # Get all users in this conversation
  def users
    User.where(id: [ sender_id, receiver_id ])
  end

  # Mark all messages as read for a user
  def mark_messages_as_read_for(user)
    messages.where.not(user: user).update_all(read: true)
  end

  # Mark messages as unread for all participants except the sender
  def mark_as_unread_for_others(current_user)
    users_to_mark = users.where.not(id: current_user.id)
    users_to_mark.each do |user|
      messages.where(user: current_user, read: true)
              .update_all(read: false)
    end
  end
end
