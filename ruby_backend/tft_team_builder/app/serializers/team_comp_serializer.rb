# frozen_string_literal: true

class TeamCompSerializer
  def initialize(team_comp, request: nil, include_cards: true, meta: {}, current_user: nil)
    @team_comp = team_comp
    @request = request
    @include_cards = include_cards
    @meta = meta
    @current_user = current_user
  end

  def as_json(_options = {})
    payload = {
      id: team_comp.id,
      set: team_comp.set_identifier,
      name: team_comp.name,
      description: team_comp.description,
      winRate: team_comp.win_rate_value,
      playRate: team_comp.play_rate_value,
      notes: team_comp.notes,
      source: team_comp.source,
      championNames: team_comp.champion_names,
      size: team_comp.size || team_comp.champion_names.length,
      championCount: team_comp.champion_names.length,
      isSystemTeam: team_comp.team_type == "system",
      userId: team_comp.user_id,
      userName: team_comp.user&.email&.split("@")&.first || team_comp.user&.email,
      likesCount: team_comp.likes_count,
      favoritesCount: team_comp.favorites_count,
      commentsCount: team_comp.comments_count,
      createdAt: team_comp.created_at,
      updatedAt: team_comp.updated_at
    }

    # Add user interaction status if current_user is provided
    if current_user
      payload[:isLiked] = team_comp.likes.exists?(user_id: current_user.id)
      payload[:isFavorited] = team_comp.favorites.exists?(user_id: current_user.id)
    end

    payload[:cards] = serialized_cards if include_cards
    combined_meta = team_comp.derived_metadata
    combined_meta = combined_meta.merge(meta) if meta.present?
    payload[:meta] = combined_meta if combined_meta.present?

    payload
  end

  private

  attr_reader :team_comp, :request, :include_cards, :meta, :current_user

  def serialized_cards
    team_comp.champion_records.map do |champion|
      ChampionSerializer.new(champion, request: request).as_json
    end
  end
end
