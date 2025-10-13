# frozen_string_literal: true

module Api
  class ProfilesController < BaseController
    before_action :authenticate_user!

    def show
      render json: { user: serialize_user(current_user) }
    end

    def update
      if current_user.update(profile_params)
        render json: { user: serialize_user(current_user) }
      else
        render json: { errors: current_user.errors.full_messages }, status: :unprocessable_entity
      end
    end

    private

    def profile_params
      params.require(:user).permit(:display_name, :bio, :location, :avatar_url, :password, :password_confirmation)
    end

    def serialize_user(user)
      UserSerializer.new(user).as_json
    end
  end
end
