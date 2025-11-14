class Like < ApplicationRecord
  belongs_to :user
  belongs_to :team_comp, counter_cache: true

  validates :user_id, uniqueness: { scope: :team_comp_id, message: "已经点赞过这个阵容" }
end
