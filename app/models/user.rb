class User < ApplicationRecord
  has_secure_password
  has_many :products, dependent: :destroy

  validates :username, presence: true, uniqueness: true
  validates :email, format: { with: /@/, message: "should look like an email address" }, uniqueness: true, allow_blank: true
  def self.new_from_hash(user_hash)
    user = User.new user_hash
    user.password_digest = 0
    user
  end

  def has_password?
    self.password_digest.nil? || self.password_digest != "0"
  end
end
