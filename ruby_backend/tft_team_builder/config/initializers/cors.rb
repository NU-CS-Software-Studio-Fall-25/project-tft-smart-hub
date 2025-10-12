# frozen_string_literal: true

# Allow the SPA dev server (and optionally other origins through env var) to talk to this API.
Rails.application.config.middleware.insert_before 0, Rack::Cors do
  allow do
    origins(*ENV.fetch("FRONTEND_ORIGINS", "http://localhost:5173").split(","))
    resource "/api/*",
             headers: :any,
             methods: %i[get post put patch delete options head],
             max_age: 600
  end
end
