FactoryBot.define do
  factory :champion do
    sequence(:name) { |n| "Champion#{n}" }
    tier { rand(1..5) }
    cost { tier }
    traits { ["Trait1", "Trait2"] }
    image_url { Faker::Internet.url }
    sprite_name { "champions.png" }
    sprite_x { 0 }
    sprite_y { 0 }
    sprite_w { 100 }
    sprite_h { 100 }
    sequence(:api_id) { |n| "TFT15_Champion#{n}" }
    set_identifier { "TFT15" }
  end
end
