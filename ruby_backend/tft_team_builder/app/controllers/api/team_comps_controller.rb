# frozen_string_literal: true

module Api
  # = Team Compositions API Controller
  #
  # Provides REST API endpoints for managing Teamfight Tactics team compositions.
  # Handles CRUD operations, filtering, searching, and pagination.
  #
  # == Routes
  # * GET /api/team_comps - List all team compositions
  # * GET /api/team_comps/:id - Show single team composition
  # * POST /api/team_comps - Create new team composition (authenticated)
  # * PATCH /api/team_comps/:id - Update team composition (authorized)
  # * DELETE /api/team_comps/:id - Delete team composition (authorized)
  #
  # == Query Parameters
  # * +type+ - Filter by team type ('system' or 'user')
  # * +set+ - Filter by TFT set identifier
  # * +search+ - Search teams by name or champions
  # * +per+/+limit+ - Items per page (1-200, default 10)
  # * +page+ - Page number for pagination
  # * +include_cards+ - Include champion details when true
  # * +sort+ - Sort field (win_rate, created_at, etc.)
  #
  # == Authentication
  # * Requires authentication for create/update/delete operations
  # * GET requests are public (except when unauthorized)
  #
  # == Authorization
  # * Users can only modify their own team compositions
  # * System teams are read-only for regular users
  #
  class TeamCompsController < BaseController
    before_action :set_team_comp, only: %i[show update destroy]
    before_action :authenticate_user!, only: %i[create update destroy]
    before_action :authorize_team_modification!, only: %i[update destroy]

    def index
      scope = team_comp_scope.order(win_rate: :desc, created_at: :desc)

      # Filter by team type
      case params[:type]
      when "system"
        scope = scope.system_teams
      when "user"
        scope = scope.user_teams
      end

      # Use Pagy for pagination (default 10 items per page from initializer)
      # Allow override with per/limit param, clamped to 1-200
      items_per_page = params.fetch(:per, params.fetch(:limit, 10)).to_i.clamp(1, 200)
      pagy, comps = pagy(scope, limit: items_per_page)

      # Preload all champions for this set to avoid N+1 queries
      preload_champions_for_set(comps) if include_cards?
      
      # Preload user likes and favorites to avoid N+1 queries
      preload_user_interactions(comps) if current_user

      payload = comps.map { |comp| serialize(comp, include_cards: include_cards?) }

      # Disable caching to ensure fresh data (likes/favorites counts)
      expires_in 0, public: false, must_revalidate: true

      render json: {
        teams: payload,
        meta: {
          page: pagy.page,
          per: pagy.limit,
          total: pagy.count,
          totalPages: pagy.pages,
          hasMore: pagy.page < pagy.pages,
          search: search_query.presence,
          set: requested_set.presence
        }.compact
      }
    end

    def show
      render json: serialize(@team_comp)
    end

    def create
      team_comp = TeamComp.new(team_comp_attributes)
      team_comp.user = current_user

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
      include_names = Champion.for_set(requested_set).where(id: include_ids).pluck(:name)

      results = team_comp_scope.order(win_rate: :desc, created_at: :desc).map do |team_comp|
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

      sorted = results.sort_by { |entry| [ -entry[:matches].length, -(entry[:team_comp].win_rate_value || 0.0) ] }
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

    def authorize_team_modification!
      return if current_user.admin?
      return if @team_comp.user_id == current_user.id

      render json: { error: "You are not authorized to modify this team" }, status: :forbidden
    end

    def include_cards?
      ActiveModel::Type::Boolean.new.cast(params.fetch(:include_cards, true))
    end

    def serialize(team_comp, include_cards: true, meta: {})
      TeamCompSerializer.new(team_comp, request: request, include_cards:, meta:, current_user: current_user).as_json
    end

    def set_team_comp
      @team_comp = TeamComp.find_by(id: params[:id])
      render_not_found("Team comp") unless @team_comp
    end

    def team_comp_attributes
      permitted = params.require(:team_comp).permit(:name, :description, :notes, :source, :win_rate, :play_rate,
                                                    :set_identifier, champion_ids: [], champion_names: [], champions: [])

      names = Array(permitted.delete(:champion_names)).map(&:to_s)
      ids = Array(permitted.delete(:champion_ids)).map(&:to_i)
      names += Array(permitted.delete(:champions)).map(&:to_s)
      names += Champion.where(id: ids).pluck(:name)

      permitted[:champions] = names.map(&:strip).reject(&:blank?).uniq.join(", ")
      permitted[:win_rate] = normalize_rate(permitted[:win_rate])
      permitted[:play_rate] = normalize_rate(permitted[:play_rate])
      permitted[:set_identifier] = sanitized_set_identifier(permitted[:set_identifier])

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

    def sanitized_set_identifier(current_value)
      current_value.presence || requested_set || @team_comp&.set_identifier || TeamComp::DEFAULT_SET_IDENTIFIER
    end

    def requested_set
      params[:set].presence || params[:set_identifier].presence
    end

    def team_comp_scope
      scope = TeamComp.for_set(requested_set)
      if search_query.present?
        term = "%#{search_query.downcase}%"
        scope = scope.where("LOWER(name) LIKE :term OR LOWER(champions) LIKE :term", term:)
      end
      scope
    end

    def search_query
      params[:search]&.to_s&.strip
    end

    def preload_champions_for_set(comps)
      return if comps.empty?

      # Collect all unique champion names from all team comps
      all_champion_names = comps.flat_map(&:champion_names).uniq
      return if all_champion_names.empty?

      # Single query to fetch all champions
      set = comps.first.set_identifier
      champions_hash = Champion.for_set(set)
                              .where(name: all_champion_names)
                              .index_by(&:name)

      # Cache champions in each team_comp instance
      comps.each do |comp|
        comp.instance_variable_set(:@champion_records_cache,
          comp.champion_names.map { |name| champions_hash[name] }.compact
        )
      end
    end
    
    def preload_user_interactions(comps)
      return if comps.empty? || !current_user
      
      team_comp_ids = comps.map(&:id)
      
      # Fetch all likes for current user in a single query
      liked_team_ids = Like.where(user_id: current_user.id, team_comp_id: team_comp_ids)
                           .pluck(:team_comp_id)
                           .to_set
      
      # Fetch all favorites for current user in a single query
      favorited_team_ids = Favorite.where(user_id: current_user.id, team_comp_id: team_comp_ids)
                                   .pluck(:team_comp_id)
                                   .to_set
      
      # Cache the results in each team_comp instance
      comps.each do |comp|
        comp.instance_variable_set(:@is_liked_by_current_user, liked_team_ids.include?(comp.id))
        comp.instance_variable_set(:@is_favorited_by_current_user, favorited_team_ids.include?(comp.id))
      end
    end
  end
end
