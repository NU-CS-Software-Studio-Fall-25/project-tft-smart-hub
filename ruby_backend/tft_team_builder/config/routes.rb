# frozen_string_literal: true

Rails.application.routes.draw do
  namespace :api do
    post "auth/register", to: "auth#register"
    post "auth/verify_email", to: "auth#verify_email"
    post "auth/resend_verification", to: "auth#resend_verification"
    post "auth/login", to: "auth#login"
    get "auth/me", to: "auth#me"

    resource :profile, only: %i[show update], controller: :profiles

    resources :champions, only: %i[index show]
    resources :team_comps, except: %i[new edit] do
      collection do
        post :recommendations
      end
      member do
        post :like, to: "likes#create"
        delete :like, to: "likes#destroy"
        get :like, to: "likes#check"
        
        post :favorite, to: "favorites#create"
        delete :favorite, to: "favorites#destroy"
        get :favorite, to: "favorites#check"
      end
      resources :comments, only: %i[index create destroy]
    end
    
    resources :favorites, only: %i[index]
  end

  get "up" => "rails/health#show", as: :rails_health_check

  # Serve Vue SPA - catch all routes and serve index.html
  # This must be the last route
  get "*path", to: "application#fallback_index_html", constraints: ->(request) do
    !request.xhr? && request.format.html?
  end
end
