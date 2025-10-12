# frozen_string_literal: true

module Api
  class ChampionsController < BaseController
    def index
      champions = Champion.order(:tier, :name)
      render json: champions.map { |champion| serialize(champion) }
    end

    def show
      champion = Champion.find_by(id: params[:id])
      return render_not_found("Champion") unless champion

      render json: serialize(champion)
    end

    private

    def serialize(champion)
      ChampionSerializer.new(champion, request: request).as_json
    end
  end
end
