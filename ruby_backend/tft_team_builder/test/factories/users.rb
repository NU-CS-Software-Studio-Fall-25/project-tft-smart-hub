FactoryBot.define do
  factory :user do
    email { Faker::Internet.unique.email }
    password { "Test123!@#" }
    password_confirmation { "Test123!@#" }
    role { "user" }
    email_verified_at { Time.current }

    trait :admin do
      role { "admin" }
    end

    trait :with_google do
      provider { "google" }
      uid { Faker::Internet.uuid }
      email_verified_at { Time.current }
      password_digest { "" }
    end
  end
end
