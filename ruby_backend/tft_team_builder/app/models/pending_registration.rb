class PendingRegistration < ApplicationRecord
  has_secure_password

  VERIFICATION_CODE_TTL = 2.hours

  validates :email, presence: true, uniqueness: { case_sensitive: false }
  validates :verification_code, presence: true

  before_validation :normalize_email, :generate_verification_code, :set_expiration, on: :create
  after_create :send_verification_email

  scope :expired, -> { where("expires_at < ?", Time.current) }
  scope :valid_codes, -> { where("expires_at >= ?", Time.current) }

  def expired?
    expires_at < Time.current
  end

  def verify_code(code)
    return false if expired?
    return false if verification_code.blank? || code.blank?

    ActiveSupport::SecurityUtils.secure_compare(verification_code.upcase, code.upcase)
  end

  def create_user!
    return nil if expired?

    # 创建用户，直接复制加密后的密码（避免重复加密）
    user = User.new(
      email: email,
      display_name: display_name,
      role: "user",
      email_verified_at: Time.current  # 验证成功后直接标记为已验证
    )

    # 直接复制已加密的密码摘要
    user.password_digest = self.password_digest
    user.save!(validate: false)  # 跳过密码验证，因为我们直接设置了 password_digest

    # 创建用户成功后删除临时记录
    destroy

    user
  end

  def resend_code!
    self.verification_code = SecureRandom.alphanumeric(6).upcase
    self.code_sent_at = Time.current
    self.expires_at = VERIFICATION_CODE_TTL.from_now
    save!

    # Send new verification email
    send_verification_email
  end

  def send_verification_email
    PendingRegistrationMailer.with(pending: self).verification_email
  end

  # 清理过期的注册记录（可以用定时任务调用）
  def self.cleanup_expired!
    expired.destroy_all
  end

  private

  def normalize_email
    self.email = email.to_s.downcase.strip if email.present?
  end

  def generate_verification_code
    self.verification_code ||= SecureRandom.alphanumeric(6).upcase
    self.code_sent_at ||= Time.current
  end

  def set_expiration
    self.expires_at ||= VERIFICATION_CODE_TTL.from_now
  end
end
