# frozen_string_literal: true

class User < ApplicationRecord
  has_secure_password

  ROLES = %w[user admin].freeze

  validates :email, presence: true, uniqueness: { case_sensitive: false }
  validates :role, inclusion: { in: ROLES }
  validates :password, length: { minimum: 8 }, allow_nil: true

  before_validation :normalize_role, :normalize_email

  def admin?
    role == "admin"
  end

  private

  def normalize_role
    self.role = role.to_s.downcase.presence || "user"
  end

  def normalize_email
    self.email = email.to_s.downcase.strip
  end
end
