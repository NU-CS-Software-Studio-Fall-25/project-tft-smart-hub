class Comment < ApplicationRecord
  belongs_to :user
  belongs_to :team_comp, counter_cache: true

  validates :content, presence: true, length: { minimum: 1, maximum: 500 }

  default_scope { order(created_at: :desc) }
end
