# frozen_string_literal: true

class UserSerializer
  def initialize(user)
    @user = user
  end

  def as_json(_options = {})
    {
      id: user.id,
      email: user.email,
      emailVerified: user.email_verified?,
      role: user.role,
      displayName: user.display_name,
      bio: user.bio,
      location: user.location,
      avatarUrl: user.avatar_url,
      createdAt: user.created_at,
      updatedAt: user.updated_at
    }
  end

  private

  attr_reader :user
end
