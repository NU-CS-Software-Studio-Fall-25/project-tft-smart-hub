# frozen_string_literal: true

module Api
  class AuthController < BaseController

    def register
      user = User.new(register_params)

      if user.save
        # Send verification email
        UserMailer.with(user: user).verification_email.deliver_later
        
        render json: { 
          message: "Registration successful! Please check your email for verification code.",
          user: serialize_user(user).merge(email_verified: false)
        }, status: :created
      else
        render json: { errors: user.errors.full_messages }, status: :unprocessable_entity
      end
    end

    def verify_email
      user = User.find_by(email: verify_email_params[:email].to_s.downcase.strip)
      
      if user&.verify_email(verify_email_params[:token])
        render json: auth_payload(user)
      else
        render json: { errors: ["Invalid verification token"] }, status: :unprocessable_entity
      end
    end

    def resend_verification
      user = User.find_by(email: resend_params[:email].to_s.downcase.strip)
      
      if user && !user.email_verified?
        user.resend_verification_email
        UserMailer.with(user: user).verification_email.deliver_later
        render json: { message: "Verification email sent successfully" }
      else
        render json: { errors: ["User not found or already verified"] }, status: :not_found
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

    def verify_email_params
      params.require(:user).permit(:email, :token)
    end

    def resend_params
      params.require(:user).permit(:email)
    end
  end
end
