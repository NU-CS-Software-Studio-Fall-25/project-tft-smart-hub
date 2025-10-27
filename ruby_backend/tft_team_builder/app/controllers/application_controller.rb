class ApplicationController < ActionController::Base
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  # Fallback to serve Vue SPA for non-API routes
  def fallback_index_html
    # Set cache control headers to prevent stale cached versions
    response.headers["Cache-Control"] = "no-cache, no-store, must-revalidate"
    response.headers["Pragma"] = "no-cache"
    response.headers["Expires"] = "0"
    
    render file: Rails.public_path.join("index.html")
  end
end
