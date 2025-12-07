# frozen_string_literal: true

require "json"
require "digest"

module Services
  module Importers
    class TftDataImporter
    CHAMPION_ID_PATTERN = /TFT\d+_[A-Za-z]+/.freeze

    def initialize(set_identifier: TeamComp::DEFAULT_SET_IDENTIFIER,
                   set_name: "Into the Arcane",
                   data_dir: Rails.root.join("lib", "tasks", "data"),
                   truncate: true,
                   logger: Rails.logger)
      @set_identifier = set_identifier
      @set_name = set_name
      @data_dir = data_dir
      @truncate = truncate
      @logger = logger
    end

    def call
      ActiveRecord::Base.transaction do
        purge_existing! if truncate?
        import_traits
        import_champions
        import_team_comps
      end
    end

    private

    attr_reader :set_identifier, :set_name, :data_dir, :logger

    def truncate?
      @truncate
    end

    def purge_existing!
      TeamComp.where(set_identifier: set_identifier).delete_all
      Champion.where(set_identifier: set_identifier).delete_all
      Trait.where(set_identifier: set_identifier).delete_all
    end

    def import_traits
      log "Importing #{traits_payload.size} traits for #{set_identifier}"
      traits_payload.each do |trait|
        Trait.create!(
          api_id: trait.fetch("id"),
          name: trait.fetch("name"),
          image_full: File.join("tft-trait", trait.fetch("full")),
          image_sprite: trait["sprite"],
          image_x: trait["x"],
          image_y: trait["y"],
          image_w: trait["w"],
          image_h: trait["h"],
          set_identifier: set_identifier
        )
      end
    end

    def import_champions
      log "Importing #{champions_payload.size} champions for #{set_identifier}"
      trait_map = champion_trait_mapping.index_by { |entry| entry["championId"] }

      champions_payload.each do |champ|
        Champion.create!(
          api_id: champ.fetch("id"),
          name: champ.fetch("name"),
          tier: champ["cost"],
          cost: champ["cost"],
          traits: format_trait_names(trait_map[champ["id"]]&.fetch("traits", [])),
          image_url: File.join("tft-champion", champ.fetch("full")),
          sprite_name: champ["sprite"],
          sprite_x: champ["x"],
          sprite_y: champ["y"],
          sprite_w: champ["w"],
          sprite_h: champ["h"],
          set_identifier: set_identifier
        )
      end
    end

    def import_team_comps
      champion_lookup = Champion.where(set_identifier: set_identifier).index_by(&:api_id)
      trait_lookup = Trait.where(set_identifier: set_identifier).pluck(:api_id, :name).to_h
      total_games = composition_entries.sum { |(_, data)| data.fetch("count", 0).to_i }

      log "Importing #{composition_entries.size} compositions (#{total_games} total games)"
      imported = 0

      composition_entries.each do |composition_key, comp_data|
        champion_ids = parse_champion_ids(composition_key)
        champions = champion_ids.map { |cid| champion_lookup[cid] }
        next if champions.any?(&:nil?)

        names = champions.map(&:name)
        comp_hash = composition_hash(champion_ids)

        next if TeamComp.exists?(composition_hash: comp_hash)

        trait_summary = build_trait_summary(comp_data["traits"], trait_lookup)
        name = build_comp_name(names, trait_summary, comp_data)
        description = build_comp_description(names, trait_summary, comp_data)

        TeamComp.create!(
          set_identifier: set_identifier,
          name: name,
          description: description,
          champions: names.join(", "),
          win_rate: comp_data["top1_rate"] || comp_data["win_rate"],
          play_rate: normalized_play_rate(comp_data["count"], total_games),
          notes: build_notes(trait_summary),
          source: "#{set_name} import",
          composition_key: composition_key,
          composition_hash: comp_hash,
          size: comp_data["size"],
          play_count: comp_data["count"],
          win_count: comp_data["top1"],
          top4_count: comp_data["top4"],
          avg_placement: comp_data["avg_placement"],
          top1_rate: comp_data["top1_rate"],
          top2_rate: comp_data["top2_rate"],
          top3_rate: comp_data["top3_rate"],
          top4_rate: comp_data["top4_rate"],
          team_type: "system",
          raw_data: comp_data
        )

        imported += 1
      end

      log "Imported #{imported} compositions for #{set_identifier}"
    end

    def normalized_play_rate(count, total_games)
      return if total_games.to_i <= 0

      (count.to_f / total_games).round(6)
    end

    def parse_champion_ids(key)
      units_segment = key.to_s.split("__TRAITS_").first.to_s
      units_segment = units_segment.sub(/^UNITS_/, "")
      units_segment.scan(CHAMPION_ID_PATTERN)
    end

    def composition_hash(ids)
      Digest::MD5.hexdigest(ids.sort.join(","))
    end

    def build_trait_summary(raw_traits, lookup)
      Array(raw_traits).map do |trait|
        api_id = trait["name"]
        {
          api_id: api_id,
          name: lookup[api_id] || api_id.to_s.sub(/^TFT\d+_/, ""),
          units: trait["num_units"],
          tier: trait["tier_current"],
          style: trait["style"]
        }
      end.sort_by { |entry| [ -entry[:units].to_i, -entry[:tier].to_i ] }
    end

    def build_comp_name(names, trait_summary, comp_data)
      featured_trait = trait_summary.first&.fetch(:name, nil)
      carry = select_carry(names)
      size = comp_data["size"] || names.size

      [ featured_trait, "#{size}-Unit Core", carry && "(#{carry} Carry)" ].compact.join(" ")
    end

    def build_comp_description(names, trait_summary, comp_data)
      lines = []
      lines << "Lineup: #{names.join(', ')}"
      trait_text = trait_summary.first(3).map { |trait| "#{trait[:name]} #{trait[:units]}u" }
      lines << "Key traits: #{trait_text.join(' / ')}" if trait_text.any?
      if comp_data["avg_placement"]
        lines << format("Avg placement %.2f over %d games", comp_data["avg_placement"], comp_data["count"])
      end
      lines.join(". ")
    end

    def build_notes(trait_summary)
      return if trait_summary.empty?

      "Imported strengths: " + trait_summary.first(4).map { |trait| trait[:name] }.join(", ")
    end

    def select_carry(names)
      return if names.empty?

      champion_costs = Champion.where(set_identifier: set_identifier, name: names).pluck(:name, :cost, :tier).to_h do |name, cost, tier|
        [ name, cost || tier || 0 ]
      end

      names.max_by { |name| champion_costs[name] || 0 }
    end

    def format_trait_names(list)
      Array(list).map(&:to_s).reject(&:blank?).join(" / ").presence || "Unknown"
    end

    def champions_payload
      @champions_payload ||= load_json("tft15_champions_clean.json")
    end

    def champion_trait_mapping
      @champion_trait_mapping ||= load_json("tft15_champion_trait_mapping.json")
    end

    def traits_payload
      @traits_payload ||= load_json("tft15_traits_clean.json")
    end

    def composition_entries
      @composition_entries ||= load_json("tft15_compositions_clean.json").to_a
    end

    def load_json(filename)
      filepath = data_dir.join(filename)
      JSON.parse(File.read(filepath))
    rescue Errno::ENOENT => e
      raise IOError, "Missing import file #{filepath}: #{e.message}"
    end

    def log(message)
      logger&.info("[tft-data-import] #{message}")
    end
    end
  end
end
