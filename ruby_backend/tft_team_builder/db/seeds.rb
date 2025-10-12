# frozen_string_literal: true

require "json"

def load_json(file_name)
  filepath = Rails.root.join("lib", "tasks", "data", file_name)
  JSON.parse(File.read(filepath))
end

puts "============================================="
puts "             Seeding Database"
puts "============================================="

puts "\nLoading JSON sources..."
champions_data = load_json("tft-champion.json")
traits_data = load_json("tft-trait.json")
champion_traits = load_json("champion-traits.json")["mappings"]

traits_lookup = champion_traits.index_by { |entry| entry["championId"] }
puts "Loaded #{champions_data.count} champions, "\
     "#{traits_data.count} traits, and #{champion_traits.count} trait mappings."

puts "\nCleaning old data..."
TeamComp.delete_all
Champion.delete_all
Trait.delete_all
puts "Tables truncated."

puts "\nSeeding traits..."
traits_data.each do |trait|
  Trait.create!(
    api_id: trait["id"],
    name: trait["name"],
    image_full: trait["icon"]
  )
end
puts "Created #{Trait.count} traits."

puts "\nSeeding champions..."
champions_data.each do |champ|
  mapping = traits_lookup[champ["id"]] || {}
  traits = Array(mapping["traits"]).presence || ["Unknown"]

  Champion.create!(
    name: champ["name"],
    tier: champ["tier"],
    traits: traits.join(" / "),
    image_url: "tft-champion/#{champ['icon']}",
    sprite_name: champ["sprite"],
    sprite_x: champ["x"],
    sprite_y: champ["y"],
    sprite_w: champ["w"],
    sprite_h: champ["h"]
  )
end
puts "Created #{Champion.count} champions."

puts "\nSeeding sample team compositions..."
sample_comps = [
  {
    name: "Blade Vanguard Primer",
    description: "Example comp seeded for local development. Mix of frontline blades and sustain.",
    champions: "Aatrox, Darius, Gwen, Yasuo, Yone, Kayle",
    win_rate: 0.58,
    play_rate: 0.12,
    notes: "Seed data only. Replace with real curated comps once integration is complete.",
    source: "seed"
  },
  {
    name: "Void Rift Artillery",
    description: "Long-range magic damage core built around Vel'Koz and support control tools.",
    champions: "Vel'Koz, Lux, Sona, Thresh, Syndra, Neeko",
    win_rate: 0.62,
    play_rate: 0.08,
    notes: "Demonstrates high match rate comp for recommendations API.",
    source: "seed"
  },
  {
    name: "Swiftshot Tempo",
    description: "Aggressive early tempo comp leveraging swiftshot trait for fast pivots.",
    champions: "Ashe, Kindred, Ezreal, Shen, Taric, Riven",
    win_rate: 0.55,
    play_rate: 0.15,
    notes: "Helps populate the builder list when no filters are supplied.",
    source: "seed"
  }
]

sample_comps.each do |attrs|
  TeamComp.create!(attrs)
end
puts "Created #{TeamComp.count} team compositions."

puts "\n============================================="
puts "            Seeding Complete!"
puts "============================================="
