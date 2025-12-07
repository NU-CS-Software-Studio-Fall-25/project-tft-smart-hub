# Resend email service configuration
# Get your API key from https://resend.com/api-keys

Resend.configure do |config|
  config.api_key = ENV.fetch("RESEND_API_KEY", "test_key")
end
