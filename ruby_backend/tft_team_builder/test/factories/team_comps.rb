FactoryBot.define do
  factory :team_comp do
    name { Faker::Game.title }
    description { Faker::Lorem.paragraph }
    champions { "Aatrox, Braum, Caitlyn" }
    set_identifier { "TFT15" }
    association :user
    team_type { "user" }

    trait :system do
      team_type { "system" }
      user { nil }
    end

    trait :with_champions do
      champions { "Aatrox, Braum, Caitlyn, Darius, Ekko" }
    end
  end
end
