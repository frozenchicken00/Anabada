class Comment < ApplicationRecord
  belongs_to :product
  belongs_to :user, optional: true
  belongs_to :parent_comment, class_name: "Comment", optional: true
  has_many :replies, -> { order(helpful_vote: :desc) }, class_name: "Comment", foreign_key: "parent_comment_id", dependent: :destroy
  has_many :votes, dependent: :destroy
  has_many :voters, through: :votes, source: :user

  validates :content, presence: true
  validates :helpful_vote, numericality: { only_integer: true, greater_than_or_equal_to: 0 }

  # Helper method to check if a comment is a reply
  def reply?
    parent_comment_id.present?
  end

  # Check if a user has voted on this comment
  def voted_by?(user)
    return false unless user
    votes.exists?(user_id: user.id)
  end

  # Get replies count for a specific comment
  def replies_count
    replies.count
  end

  # Get nested replies (replies to replies)
  def nested_replies
    Comment.where(parent_comment_id: replies.pluck(:id))
  end
end

# Force reload of the model schema
Comment.reset_column_information
