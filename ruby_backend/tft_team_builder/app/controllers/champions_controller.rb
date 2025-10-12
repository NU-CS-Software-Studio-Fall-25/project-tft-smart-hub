class ChampionsController < ApplicationController
  # 这个方法对应 "英雄列表" 页面 (GET /champions)
  def index
    # 从数据库中获取所有 Champion 记录，并按费用(tier)排序
    @champions = Champion.all.order(:tier)
  end

  # 这个方法对应 "英雄详情" 页面 (GET /champions/:id)
  # 我们之后会用到
  def show
    @champion = Champion.find(params[:id])
  end
end