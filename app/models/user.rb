class User < ApplicationRecord
  attr_accessor :remember_token

  has_many :tasks, dependent: :destroy
  before_save { self.email = email.downcase }
  before_destroy :must_not_destroy_last_admin
  validates :name, presence: true, length: { maximum: 50 }
  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-]+(\.[a-z\d\-]+)*\.[a-z]+\z/i
  validates :email, presence: true, length: { maximum: 255 }, format: { with: VALID_EMAIL_REGEX }, uniqueness: true
  validates :password, presence: true, length: { minimum: 8 }

  has_secure_password

  def self.digest(string)
    cost = ActiveModel::SecurePassword.min_cost ? BCrypt::Engine::MIN_COST : BCrypt::Engine.cost
    BCrypt::Password.create(string, cost: cost)
  end

  def self.new_token
    SecureRandom.urlsafe_base64
  end

  def self.find_or_create_guest_user
    find_or_create_by(email: 'guest@example.com') do |user|
      user.name = 'guest'
      user.password = 'password'
      user.admin = false
    end
  end

  def remember
    self.remember_token = User.new_token
    update_attribute(:remember_digest, User.digest(remember_token))
    remember_digest
  end

  def session_token
    remember_digest || remember
  end

  def authenticated?(remember_token)
    return false if remember_digest.nil?

    BCrypt::Password.new(remember_digest).is_password?(remember_token)
  end

  def forget
    update_attribute(:remember_digest, nil)
  end

  private

  def must_not_destroy_last_admin
    if admin? && User.where(admin: true).count == 1
      errors.add(:base, '管理者ユーザーは最低一人必要です')
      throw(:abort)
    end
  end
end
