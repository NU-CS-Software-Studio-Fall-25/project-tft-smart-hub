# frozen_string_literal: true

# Allow the SPA dev server (and optionally other origins through env var) to talk to this API.
Rails.application.config.middleware.insert_before 0, Rack::Cors do
  allow do
    # Allow both localhost and 127.0.0.1 for local development
    origins(*ENV.fetch("FRONTEND_ORIGINS", "http://localhost:5173,http://127.0.0.1:5173,http://localhost:5174,http://127.0.0.1:5174").split(","))
    resource "/api/*",
             headers: :any,
             methods: %i[get post put patch delete options head],
             max_age: 600
  end
end
