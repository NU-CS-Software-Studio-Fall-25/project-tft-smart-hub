class PagesController < ApplicationController
  # Disable caching for SPA index page to ensure updates are immediately visible
  before_action :set_no_cache_headers

  def home
  end

  private

  def set_no_cache_headers
    response.headers["Cache-Control"] = "no-cache, no-store, must-revalidate"
    response.headers["Pragma"] = "no-cache"
    response.headers["Expires"] = "0"
  end
end
