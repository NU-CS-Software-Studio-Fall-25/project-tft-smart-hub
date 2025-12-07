# frozen_string_literal: true

module Api
  class ProfilesController < BaseController
    before_action :authenticate_user!

    def show
      render json: { user: serialize_user(current_user) }
    end

    def update
      # Handle password changes separately
      if password_params_present?
        update_password
      else
        update_profile
      end
    end

    private

    def update_profile
      if current_user.update(profile_params.except(:password, :password_confirmation, :current_password))
        render json: { user: serialize_user(current_user) }
      else
        render json: { errors: current_user.errors.full_messages }, status: :unprocessable_entity
      end
    end

    def update_password
      # Verify current password before allowing change
      unless current_user.authenticate_current_password(password_params[:current_password])
        return render json: { errors: [ "Current password is incorrect" ] }, status: :unprocessable_entity
      end

      # Update password
      if current_user.update(password_params.slice(:password, :password_confirmation))
        render json: { user: serialize_user(current_user), message: "Password updated successfully" }
      else
        render json: { errors: current_user.errors.full_messages }, status: :unprocessable_entity
      end
    end

    def password_params_present?
      password_params[:password].present? || password_params[:password_confirmation].present?
    end

    def password_params
      params.require(:user).permit(:current_password, :password, :password_confirmation)
    end

    def profile_params
      params.require(:user).permit(:display_name, :bio, :location, :avatar_url, :password, :password_confirmation, :current_password)
    end

    def serialize_user(user)
      UserSerializer.new(user).as_json
    end
  end
end
