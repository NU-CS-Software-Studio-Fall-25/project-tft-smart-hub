# frozen_string_literal: true

class TeamCompSerializer
  def initialize(team_comp, request:, include_cards: true, meta: {})
    @team_comp = team_comp
    @request = request
    @include_cards = include_cards
    @meta = meta
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
      createdAt: team_comp.created_at,
      updatedAt: team_comp.updated_at
    }

    payload[:cards] = serialized_cards if include_cards
    combined_meta = team_comp.derived_metadata
    combined_meta = combined_meta.merge(meta) if meta.present?
    payload[:meta] = combined_meta if combined_meta.present?

    payload
  end

  private

  attr_reader :team_comp, :request, :include_cards, :meta

  def serialized_cards
    team_comp.champion_records.map do |champion|
      ChampionSerializer.new(champion, request: request).as_json
    end
  end
end
