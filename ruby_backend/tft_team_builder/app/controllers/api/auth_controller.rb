# frozen_string_literal: true

module Api
  class AuthController < BaseController

    def register
      user = User.new(register_params)

      if user.save
        render json: auth_payload(user), status: :created
      else
        render json: { errors: user.errors.full_messages }, status: :unprocessable_entity
      end
    end

    def login
      user = User.find_by(email: login_params[:email].to_s.downcase.strip)

      if user&.authenticate(login_params[:password])
        render json: auth_payload(user)
      else
        render_unauthorized("Invalid email or password")
      end
    end

    def me
      return render_unauthorized unless current_user

      render json: { user: serialize_user(current_user) }
    end

    private

    def auth_payload(user)
      {
        token: JsonWebToken.encode({ sub: user.id }),
        user: serialize_user(user)
      }
    end

    def serialize_user(user)
      UserSerializer.new(user).as_json
    end

    def register_params
      attrs = params.require(:user).permit(:email, :password, :password_confirmation,
                                           :display_name, :bio, :location, :avatar_url)
      attrs[:role] = "user"
      attrs
    end

    def login_params
      params.require(:user).permit(:email, :password)
    end
  end
end
