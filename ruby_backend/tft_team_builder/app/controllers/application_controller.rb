class ApplicationController < ActionController::Base
  # Fallback to serve Vue SPA for non-API routes
  def fallback_index_html
    render file: Rails.public_path.join("index.html"), layout: false
  end
end
