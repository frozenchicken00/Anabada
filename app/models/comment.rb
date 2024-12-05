class Comment < ApplicationRecord
  belongs_to :product
  belongs_to :parent_comment, class_name: "Comment", optional: true
  has_many :replies, -> { order(helpful_vote: :desc) }, class_name: "Comment", foreign_key: "parent_comment_id", dependent: :destroy

  validates :content, presence: true
  validates :helpful_vote, numericality: { only_integer: true, greater_than_or_equal_to: 0 }

  # Helper method to check if a comment is a reply
  def reply?
    parent_comment_id.present?
  end
end
