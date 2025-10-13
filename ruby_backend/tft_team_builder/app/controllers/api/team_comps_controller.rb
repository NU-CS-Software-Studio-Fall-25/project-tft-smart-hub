# frozen_string_literal: true

module Api
  class TeamCompsController < BaseController
    before_action :set_team_comp, only: %i[show update destroy]
    before_action :authenticate_user!, only: %i[create update destroy]
    before_action :require_admin!, only: %i[update destroy]

    def index
      comps = TeamComp.order(win_rate: :desc, created_at: :desc)
      limit = params.fetch(:limit, 50).to_i.clamp(1, 100)
      comps = comps.limit(limit)

      render json: comps.map { |comp| serialize(comp, include_cards: include_cards?) }
    end

    def show
      render json: serialize(@team_comp)
    end

    def create
      team_comp = TeamComp.new(team_comp_attributes)

      if team_comp.save
        render json: serialize(team_comp), status: :created
      else
        render json: { errors: team_comp.errors.full_messages }, status: :unprocessable_entity
      end
    end

    def update
      if @team_comp.update(team_comp_attributes)
        render json: serialize(@team_comp)
      else
        render json: { errors: @team_comp.errors.full_messages }, status: :unprocessable_entity
      end
    end

    def destroy
      @team_comp.destroy!
      head :no_content
    end

    def recommendations
      include_ids = extract_card_ids
      include_names = Champion.where(id: include_ids).pluck(:name)

      results = TeamComp.order(win_rate: :desc, created_at: :desc).map do |team_comp|
        names = team_comp.champion_names
        matches = (names & include_names)

        next if include_names.present? && matches.empty?

        {
          team_comp:,
          matches:,
          match_ratio: include_names.present? ? matches.length.to_f / include_names.length : 0.0
        }
      end.compact

      if results.empty?
        fallback = TeamComp.order(win_rate: :desc, created_at: :desc).limit(10)
        render json: {
          requestedChampionIds: include_ids,
          teams: fallback.map { |team| serialize(team, meta: { matchCount: 0 }) }
        }
        return
      end

      sorted = results.sort_by { |entry| [-entry[:matches].length, -(entry[:team_comp].win_rate_value || 0.0)] }
      top = sorted.first(params.fetch(:limit, 10).to_i.clamp(1, 25))

      payload = top.map do |entry|
        meta = {
          matchCount: entry[:matches].length,
          matchRatio: entry[:match_ratio],
          matchedChampionNames: entry[:matches],
          missingChampionNames: entry[:team_comp].champion_names - entry[:matches]
        }

        serialize(entry[:team_comp], meta:)
      end

      render json: {
        requestedChampionIds: include_ids,
        requestedChampionNames: include_names,
        teams: payload
      }
    end

    private

    def include_cards?
      ActiveModel::Type::Boolean.new.cast(params.fetch(:include_cards, true))
    end

    def serialize(team_comp, include_cards: true, meta: {})
      TeamCompSerializer.new(team_comp, request: request, include_cards:, meta:).as_json
    end

    def set_team_comp
      @team_comp = TeamComp.find_by(id: params[:id])
      render_not_found("Team comp") unless @team_comp
    end

    def team_comp_attributes
      permitted = params.require(:team_comp).permit(:name, :description, :notes, :source, :win_rate, :play_rate,
                                                    champion_ids: [], champion_names: [], champions: [])

      names = Array(permitted.delete(:champion_names)).map(&:to_s)
      ids = Array(permitted.delete(:champion_ids)).map(&:to_i)
      names += Array(permitted.delete(:champions)).map(&:to_s)
      names += Champion.where(id: ids).pluck(:name)

      permitted[:champions] = names.map(&:strip).reject(&:blank?).uniq.join(", ")
      permitted[:win_rate] = normalize_rate(permitted[:win_rate])
      permitted[:play_rate] = normalize_rate(permitted[:play_rate])

      permitted
    end

    def normalize_rate(value)
      return if value.nil?
      val = value.to_f
      return if val <= 0.0
      val = val > 1 ? val / 100.0 : val
      val.clamp(0.0, 1.0)
    end

    def extract_card_ids
      raw = params[:include_cards] || params[:include_card_ids] || params[:includeCards] || params[:includeCardIds]
      Array(raw).map { |value| value.to_i }.reject(&:zero?)
    end
  end
end
