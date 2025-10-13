# frozen_string_literal: true

Rails.application.routes.draw do
  namespace :api do
    post "auth/register", to: "auth#register"
    post "auth/login", to: "auth#login"
    get "auth/me", to: "auth#me"

    resource :profile, only: %i[show update], controller: :profiles

    resources :champions, only: %i[index show]
    resources :team_comps, except: %i[new edit] do
      collection do
        post :recommendations
      end
    end
  end

  get "up" => "rails/health#show", as: :rails_health_check
end
