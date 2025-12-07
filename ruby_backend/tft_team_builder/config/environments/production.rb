require "active_support/core_ext/integer/time"

Rails.application.configure do
  # Settings specified here will take precedence over those in config/application.rb.

  # Code is not reloaded between requests.
  config.enable_reloading = false

  # Eager load code on boot for better performance and memory savings (ignored by Rake tasks).
  config.eager_load = true

  # Full error reports are disabled.
  config.consider_all_requests_local = false

  # Turn on fragment caching in view templates.
  config.action_controller.perform_caching = true

  # Enable serving of static files from public directory
  config.public_file_server.enabled = true

  # Differentiated caching strategy:
  # 1. Assets with hash fingerprints (JS/CSS/images) get long cache (1 year)
  # 2. HTML files get no-cache to always check for updates
  # 3. Other static assets get moderate cache
  config.middleware.insert_before 0, Rack::Static,
    urls: [ "/assets" ],
    root: "public",
    header_rules: [
      # Long cache for hashed assets (Vite generates [hash] in filenames)
      [ /assets\/.*-[a-f0-9]{8,}\.(js|css|png|jpg|jpeg|gif|svg|woff|woff2|ttf|eot)$/i,
       { "Cache-Control" => "public, max-age=31536000, immutable" } ],

      # Moderate cache for sprites (1 day)
      [ /sprites\//i, { "Cache-Control" => "public, max-age=86400" } ],

      # Short cache for manifest and service worker (1 hour)
      [ /(manifest\.json|service-worker\.js|favicon\.svg|logo\.svg)$/i,
       { "Cache-Control" => "public, max-age=3600" } ],

      # No cache for HTML files - CRITICAL for updates
      [ /\.html$/i,
       { "Cache-Control" => "no-cache, no-store, must-revalidate",
         "Pragma" => "no-cache",
         "Expires" => "0" } ]
    ]

  # Default headers for public file server (applies to files not matched above)
  config.public_file_server.headers = {
    "Cache-Control" => "public, max-age=3600"  # 1 hour default
  }

  # Enable serving of images, stylesheets, and JavaScripts from an asset server.
  # config.asset_host = "http://assets.example.com"

  # Store uploaded files on the local file system (see config/storage.yml for options).
  config.active_storage.service = :local

  # Assume all access to the app is happening through a SSL-terminating reverse proxy.
  config.assume_ssl = true

  # Force all access to the app over SSL, use Strict-Transport-Security, and use secure cookies.
  config.force_ssl = true

  # Skip http-to-https redirect for the default health check endpoint.
  # config.ssl_options = { redirect: { exclude: ->(request) { request.path == "/up" } } }

  # Log to STDOUT with the current request id as a default log tag.
  config.log_tags = [ :request_id ]
  config.logger   = ActiveSupport::TaggedLogging.logger(STDOUT)

  # Change to "debug" to log everything (including potentially personally-identifiable information!)
  config.log_level = ENV.fetch("RAILS_LOG_LEVEL", "info")

  # Prevent health checks from clogging up the logs.
  config.silence_healthcheck_path = "/up"

  # Don't log any deprecations.
  config.active_support.report_deprecations = false

  # Replace the default in-process memory cache store with a durable alternative.
  config.cache_store = :solid_cache_store

  # Use inline job processing - no background queue needed for simple email sending
  # This avoids the complexity of solid_queue setup on Heroku
  config.active_job.queue_adapter = :inline

  config.action_mailer.raise_delivery_errors = false  # Don't crash on email failures
  config.action_mailer.perform_deliveries = true      # Actually send emails
  config.action_mailer.default_url_options = {
    host: ENV.fetch("MAILER_HOST") { ENV.fetch("APP_HOST", "tft-smartcomp-b3f1e37435eb.herokuapp.com") },
    protocol: ENV.fetch("MAILER_PROTOCOL", "https")
  }
  config.action_mailer.delivery_method = :smtp
  config.action_mailer.smtp_settings = {
    address: ENV.fetch("SMTP_ADDRESS", "smtp.gmail.com"),
    port: ENV.fetch("SMTP_PORT", "587").to_i,
    user_name: ENV.fetch("SMTP_USERNAME", ""),
    password: ENV.fetch("SMTP_PASSWORD", ""),
    authentication: :plain,
    enable_starttls_auto: true
  }

  # Enable locale fallbacks for I18n (makes lookups for any locale fall back to
  # the I18n.default_locale when a translation cannot be found).
  config.i18n.fallbacks = true

  # Do not dump schema after migrations.
  config.active_record.dump_schema_after_migration = false

  # Only use :id for inspections in production.
  config.active_record.attributes_for_inspect = [ :id ]

  # Enable DNS rebinding protection and other `Host` header attacks.
  # config.hosts = [
  #   "example.com",     # Allow requests from example.com
  #   /.*\.example\.com/ # Allow requests from subdomains like `www.example.com`
  # ]
  #
  # Skip DNS rebinding protection for the default health check endpoint.
  # config.host_authorization = { exclude: ->(request) { request.path == "/up" } }
end
