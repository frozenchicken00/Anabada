class User < ApplicationRecord
  has_secure_password
  attr_accessor :remember_token # Add virtual attribute

  has_many :products, dependent: :destroy
  has_many :comments, dependent: :nullify
  has_many :votes, dependent: :destroy

  # Messaging associations
  has_many :messages
  has_many :sent_conversations, class_name: "Conversation", foreign_key: "sender_id"
  has_many :received_conversations, class_name: "Conversation", foreign_key: "receiver_id"

  validates :username, presence: true, uniqueness: true
  validates :email, format: { with: /@/, message: "should look like an email address" }, uniqueness: true, allow_blank: true

  # Generates a new random token
  def self.new_token
    SecureRandom.urlsafe_base64
  end

  def self.new_from_hash(user_hash)
    user = User.new user_hash
    user.password_digest = 0
    user
  end

  def has_password?
    self.password_digest.nil? || self.password_digest != "0"
  end

  # Remembers a user in the database for use in persistent sessions.
  def remember
    self.remember_token = User.new_token
    update_attribute(:remember_digest, BCrypt::Password.create(remember_token))
  end

  # Returns true if the given token matches the digest.
  # Generalizing for different types of digests (e.g., activation, reset)
  def authenticated?(attribute, token)
    digest = send("#{attribute}_digest")
    return false if digest.nil?
    BCrypt::Password.new(digest).is_password?(token)
  end

  # Forgets a user (clears remember digest).
  def forget
    update_attribute(:remember_digest, nil)
  end

  # Get all conversations this user is involved in
  def conversations
    Conversation.involving(self.id)
  end

  # Check if user has unread messages
  def has_unread_messages?
    Message.joins(:conversation)
          .where("conversations.sender_id = ? OR conversations.receiver_id = ?", id, id)
          .where.not(user_id: id)
          .where(read: false)
          .exists?
  end

  # Count total unread messages
  def unread_messages_count
    Message.joins(:conversation)
          .where("conversations.sender_id = ? OR conversations.receiver_id = ?", id, id)
          .where.not(user_id: id)
          .where(read: false)
          .count
  end
end
