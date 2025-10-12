# frozen_string_literal: true

Rails.application.routes.draw do
  namespace :api do
    resources :champions, only: %i[index show]
    resources :team_comps, except: %i[new edit] do
      collection do
        post :recommendations
      end
    end
  end

  get "up" => "rails/health#show", as: :rails_health_check
end
