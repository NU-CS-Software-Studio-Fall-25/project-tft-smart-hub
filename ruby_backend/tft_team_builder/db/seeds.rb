# frozen_string_literal: true

require Rails.root.join("lib/services/importers/tft_data_importer")

puts "============================================="
puts "             Seeding Database"
puts "============================================="

puts "\nCleaning old user accounts..."
User.delete_all

puts "\nImporting official TFT data..."
Services::Importers::TftDataImporter.new.call
puts "Champions: #{Champion.count} | Traits: #{Trait.count} | Team comps: #{TeamComp.count}"

puts "\nCreating default accounts..."
admin = User.create!(
  email: "admin@example.com",
  password: "Admin123!",
  password_confirmation: "Admin123!",
  role: "admin",
  display_name: "Admin",
  bio: "Default administrator account",
  location: "Runeterra HQ"
)

User.create!(
  email: "player@example.com",
  password: "Player123!",
  password_confirmation: "Player123!",
  role: "user",
  display_name: "Player One",
  bio: "Strategy enthusiast ready to craft new comps.",
  location: "Piltover"
)
puts "Created #{User.count} users (including admin #{admin.email})."

puts "\n============================================="
puts "            Seeding Complete!"
puts "============================================="
