class Message < ApplicationRecord
  belongs_to :conversation
  belongs_to :user

  validates_presence_of :body, :conversation_id, :user_id

  # Default the read flag to false when creating a new message
  after_initialize :set_default_read, if: :new_record?

  # Scope for unread messages
  scope :unread, -> { where(read: false) }

  # Scope for most recent messages first
  scope :recent, -> { order(created_at: :desc) }

  private

  def set_default_read
    self.read ||= false
  end
end
