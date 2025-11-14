class Favorite < ApplicationRecord
  belongs_to :user
  belongs_to :team_comp, counter_cache: true

  validates :user_id, uniqueness: { scope: :team_comp_id, message: "已经收藏过这个阵容" }
end
