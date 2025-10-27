# frozen_string_literal: true

module Api
  class ChampionsController < BaseController
    def index
      champions = Champion.for_set(requested_set).ordered_for_picker
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

    def requested_set
      params[:set].presence
    end
  end
end
