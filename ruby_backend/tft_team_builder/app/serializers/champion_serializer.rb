# frozen_string_literal: true

require "uri"

class ChampionSerializer
  def initialize(champion, request:)
    @champion = champion
    @request = request
  end

  def as_json(_options = {})
    {
      id: champion.id,
      name: champion.name,
      tier: champion.tier,
      traits: trait_names,
      imageUrl: absolute_asset(champion.image_url),
      sprite: sprite_payload
    }
  end

  private

  attr_reader :champion, :request

  def trait_names
    champion.traits.to_s.split(" / ").map(&:strip).reject(&:blank?)
  end

  def absolute_asset(path)
    return if path.blank?
    uri = URI.parse(path)
    return path if uri.scheme.present?

    public_path = Rails.root.join("public", path.delete_prefix("/"))
    return unless File.exist?(public_path)

    "#{request.base_url}/#{path.delete_prefix('/')}"
  rescue URI::InvalidURIError
    nil
  end

  def sprite_payload
    {
      sheet: champion.sprite_name,
      x: champion.sprite_x,
      y: champion.sprite_y,
      w: champion.sprite_w,
      h: champion.sprite_h
    }.compact
  end
end
