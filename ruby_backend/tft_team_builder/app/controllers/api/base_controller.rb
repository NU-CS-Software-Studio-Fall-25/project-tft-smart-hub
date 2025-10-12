require "uri"

module Api
  class BaseController < ActionController::API
    include ActionController::MimeResponds

    around_action :set_default_format

    private

    def set_default_format
      request.format = :json
      yield
    end

    def render_not_found(resource = "resource")
      render json: { error: "#{resource} not found" }, status: :not_found
    end

    def absolute_asset_url(path)
      return if path.blank?
      uri = URI.parse(path)
      return path if uri.scheme.present?

      "#{request.base_url}/#{path.delete_prefix('/')}"
    rescue URI::InvalidURIError
      nil
    end
  end
end
