FactoryBot.define do
  factory :team_comp do
    name { Faker::Game.title }
    description { Faker::Lorem.paragraph }
    association :user
    team_type { 'user' }

    trait :system do
      team_type { 'system' }
      user { nil }
    end

    trait :with_champions do
      after(:create) do |team_comp|
        create_list(:champion, 3).each do |champion|
          team_comp.champions << champion
        end
      end
    end
  end
end
