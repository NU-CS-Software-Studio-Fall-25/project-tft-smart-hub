# frozen_string_literal: true

# Fragment caching for expensive operations
module CacheHelper
  CACHE_VERSION = "v1"
  
  def cache_key_for_team_comps(page:, per:, search: nil, set: nil)
    parts = ["team_comps", CACHE_VERSION, "p#{page}", "per#{per}"]
    parts << "search_#{Digest::MD5.hexdigest(search)}" if search.present?
    parts << "set_#{set}" if set.present?
    parts.join("_")
  end
end
