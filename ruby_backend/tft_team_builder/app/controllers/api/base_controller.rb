require "uri"

module Api
  class BaseController < ActionController::API
    include ActionController::MimeResponds
    include Pagy::Backend

    attr_reader :current_user

    around_action :set_default_format
    before_action :set_current_user

    private

    def authenticate_user!
      render_unauthorized("Login required") unless current_user
    end

    def require_admin!
      render_forbidden("Administrator privileges required") unless current_user&.admin?
    end

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

    def bearer_token
      pattern = /^Bearer (.+)$/i
      header = request.headers["Authorization"]
      header&.match(pattern)&.captures&.first
    end

    def set_current_user
      token = bearer_token
      @current_user = token ? find_user_from_token(token) : nil
    end

    def find_user_from_token(token)
      payload = JsonWebToken.decode(token)
      return unless payload && payload["sub"]

      User.find_by(id: payload["sub"])
    end

    def render_unauthorized(message = "Unauthorized")
      render json: { error: message }, status: :unauthorized
    end

    def render_forbidden(message = "Forbidden")
      render json: { error: message }, status: :forbidden
    end
  end
end
