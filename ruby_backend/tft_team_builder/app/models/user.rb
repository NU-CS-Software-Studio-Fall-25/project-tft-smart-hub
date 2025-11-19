# frozen_string_literal: true

class User < ApplicationRecord
  has_secure_password validations: false  # 关闭自动验证，因为 OAuth 用户可能没有密码

  ROLES = %w[user admin].freeze
  EMAIL_VERIFICATION_TOKEN_TTL = 2.hours
  PASSWORD_RESET_TOKEN_TTL = 2.hours

  has_many :likes, dependent: :destroy
  has_many :favorites, dependent: :destroy
  has_many :comments, dependent: :destroy
  has_many :liked_teams, through: :likes, source: :team_comp
  has_many :favorited_teams, through: :favorites, source: :team_comp

  validates :email, presence: true, uniqueness: { case_sensitive: false }
  validate :email_format, if: -> { email.present? }
  validates :role, inclusion: { in: ROLES }
  validates :password, length: { minimum: 8 }, allow_nil: true, if: :password_required?
  validate :password_complexity, if: -> { password.present? && password_required? }

  before_validation :normalize_role, :normalize_email
  before_create :generate_email_verification_token, unless: :oauth_user?

  def admin?
    role == "admin"
  end

  # OAuth methods
  def oauth_user?
    provider.present? && uid.present?
  end

  def self.from_google_oauth(payload)
    email = payload['email']
    uid = payload['sub']
    
    # 首先尝试通过 provider + uid 查找
    user = find_by(provider: 'google', uid: uid)
    
    # 如果没找到,通过邮箱查找现有用户
    if user.nil?
      user = find_by(email: email)
      
      if user
        # 用户已存在(可能是通过密码注册的),更新为 OAuth 用户
        user.update!(
          provider: 'google',
          uid: uid,
          email_verified_at: Time.current  # Google 已验证邮箱
        )
      else
        # 创建新用户
        user = create!(
          email: email,
          provider: 'google',
          uid: uid,
          display_name: payload['name'] || email.split('@').first,
          role: 'user',
          email_verified_at: Time.current,
          password_digest: ''  # OAuth 用户不需要密码
        )
      end
    end
    
    user
  end

  # Email verification methods
  def email_verified?
    email_verified_at.present?
  end

  def generate_email_verification_token
    self.email_verification_token = SecureRandom.alphanumeric(6).upcase
  end

  def deliver_verification_email!
    self.email_verification_sent_at = Time.current
    save!(validate: false) if changed?
    # Use deliver_now for immediate synchronous delivery (no background job needed)
    UserMailer.with(user: self).verification_email.deliver_now
  rescue StandardError => e
    Rails.logger.error("Failed to send verification email: #{e.message}")
    # Continue even if email fails - user can resend
  end

  def verify_email(token)
    return false unless verification_token_valid?(token)

    update(email_verified_at: Time.current, email_verification_token: nil)
  end

  def resend_verification_email
    generate_email_verification_token
    deliver_verification_email!
  end

  def verification_token_valid?(token)
    return false if email_verification_token.blank? || token.blank?
    return false if email_verification_sent_at.blank? || email_verification_sent_at < EMAIL_VERIFICATION_TOKEN_TTL.ago

    ActiveSupport::SecurityUtils.secure_compare(email_verification_token, token)
  end

  def send_password_reset_instructions
    generate_reset_password_token
    save!(validate: false)
    # Use deliver_now for immediate synchronous delivery (no background job needed)
    UserMailer.with(user: self).password_reset_email.deliver_now
  rescue StandardError => e
    Rails.logger.error("Failed to send password reset email: #{e.message}")
    # Continue even if email fails
  end

  def valid_reset_password_token?(token)
    return false if reset_password_token.blank? || token.blank?
    return false if reset_password_sent_at.blank? || reset_password_sent_at < PASSWORD_RESET_TOKEN_TTL.ago

    ActiveSupport::SecurityUtils.secure_compare(reset_password_token, token)
  end

  def clear_reset_password_token!
    update(reset_password_token: nil, reset_password_sent_at: nil)
  end

  # Verify current password before allowing password change
  def authenticate_current_password(current_password)
    authenticate(current_password)
  end

  private

  def normalize_role
    self.role = role.to_s.downcase.presence || "user"
  end

  def normalize_email
    self.email = email.to_s.downcase.strip
  end

  def password_complexity
    return if password.blank?

    # Check for at least one uppercase letter
    unless password.match?(/[A-Z]/)
      errors.add(:password, "must contain at least one uppercase letter")
    end

    # Check for at least one lowercase letter
    unless password.match?(/[a-z]/)
      errors.add(:password, "must contain at least one lowercase letter")
    end

    # Check for at least one digit
    unless password.match?(/\d/)
      errors.add(:password, "must contain at least one number")
    end

    # Check for at least one special character
    unless password.match?(/[!@#$%^&*()_+\-=\[\]{};':"\\|,.<>\/?]/)
      errors.add(:password, "must contain at least one special character (!@#$%^&*()_+-=[]{}|;:,.<>?)")
    end

    # Check for common weak passwords
    weak_passwords = %w[password 12345678 qwerty abc123 password123 admin root user test guest]
    if weak_passwords.include?(password.downcase)
      errors.add(:password, "is too common. Please choose a stronger password")
    end
  end

  def email_format
    return if email.blank?

    # Basic email format check
    unless email.match?(/\A[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}\z/)
      errors.add(:email, "must be a valid email address (e.g., user@example.com)")
      return
    end

    # Check for consecutive dots in local part
    local_part = email.split('@').first
    if local_part.include?('..')
      errors.add(:email, "must be a valid email address (consecutive dots not allowed)")
      return
    end

    # Check for consecutive dots in domain part
    domain_part = email.split('@').last
    if domain_part.include?('..')
      errors.add(:email, "must be a valid email address (consecutive dots not allowed in domain)")
      return
    end

    # Check that domain has at least one dot
    unless domain_part.include?('.')
      errors.add(:email, "must be a valid email address (domain must contain a dot)")
      return
    end
  end

  def generate_reset_password_token
    self.reset_password_token = SecureRandom.urlsafe_base64(48)
    self.reset_password_sent_at = Time.current
  end

  def password_required?
    !oauth_user?
  end
end
