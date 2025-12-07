# frozen_string_literal: true

module Api
  class AuthController < BaseController
    def register
      # 直接创建用户账户,无需邮箱验证
      user = User.new(register_params)
      user.email_verified_at = Time.current # 自动设置为已验证
      user.terms_accepted_at = Time.current if user.terms_accepted # 设置接受时间

      if user.save
        # 注册成功,直接返回token和用户信息
        render json: auth_payload(user), status: :created
      else
        render json: { errors: user.errors.full_messages }, status: :unprocessable_entity
      end
    end

    def verify_email
      email = verify_email_params[:email].to_s.downcase.strip
      code = verify_email_params[:token]

      pending = PendingRegistration.valid_codes.find_by(email: email)

      if pending.nil?
        return render json: { errors: [ "No pending registration found or code expired" ] }, status: :unprocessable_entity
      end

      if pending.verify_code(code)
        begin
          # 验证成功，创建真正的用户账户
          user = pending.create_user!
          render json: auth_payload(user)
        rescue ActiveRecord::RecordInvalid => e
          render json: { errors: [ e.message ] }, status: :unprocessable_entity
        end
      else
        render json: { errors: [ "Invalid verification code" ] }, status: :unprocessable_entity
      end
    end

    def resend_verification
      email = resend_params[:email].to_s.downcase.strip

      pending = PendingRegistration.valid_codes.find_by(email: email)

      if pending
        pending.resend_code!

        begin
          PendingRegistrationMailer.with(pending: pending).verification_email.deliver_now
        rescue StandardError => e
          Rails.logger.error("Failed to resend verification email: #{e.message}")
        end

        render json: { message: "Verification code sent successfully" }
      else
        render json: { errors: [ "No pending registration found or registration expired" ] }, status: :not_found
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

    def google_auth
      token = google_auth_params[:credential]
      terms_accepted = google_auth_params[:terms_accepted]

      begin
        # Verify the Google ID token
        validator = GoogleIDToken::Validator.new
        # In development, allow audience mismatch for localhost testing
        payload = if Rails.env.development?
          begin
            validator.check(token, ENV["GOOGLE_CLIENT_ID"])
          rescue GoogleIDToken::ValidationError => e
            if e.message.include?("audience")
              # For development, try to decode without audience validation
              require "jwt"
              decoded = JWT.decode(token, nil, false)[0]
              decoded
            else
              raise
            end
          end
        else
          validator.check(token, ENV["GOOGLE_CLIENT_ID"])
        end

        unless payload
          return render json: { errors: [ "Invalid Google token" ] }, status: :unauthorized
        end

        # Create or find user from Google OAuth
        user = User.from_google_oauth(payload)

        # Handle terms acceptance for new users or users who haven't accepted yet
        if terms_accepted && !user.terms_accepted?
          user.update!(
            terms_accepted: true,
            terms_accepted_at: Time.current
          )
        elsif !terms_accepted && !user.terms_accepted?
          # User hasn't accepted terms, return error
          return render json: { errors: [ "You must accept the Community Guidelines and Terms of Service" ], requires_terms: true, user_id: user.id }, status: :unprocessable_entity
        end

        if user.persisted?
          render json: auth_payload(user)
        else
          render json: { errors: user.errors.full_messages }, status: :unprocessable_entity
        end
      rescue GoogleIDToken::ValidationError => e
        render json: { errors: [ "Google authentication failed: #{e.message}" ] }, status: :unauthorized
      rescue StandardError => e
        Rails.logger.error("Google OAuth error: #{e.message}")
        render json: { errors: [ "Authentication failed" ] }, status: :internal_server_error
      end
    end

    def me
      return render_unauthorized unless current_user

      render json: { user: serialize_user(current_user) }
    end

    def accept_terms
      return render_unauthorized unless current_user

      if current_user.update(terms_accepted: true, terms_accepted_at: Time.current)
        render json: { message: "Terms of Service accepted successfully", user: serialize_user(current_user) }
      else
        render json: { errors: current_user.errors.full_messages }, status: :unprocessable_entity
      end
    end

    def forgot_password
      email = forgot_password_params[:email].to_s.downcase.strip
      user = User.find_by(email: email)
      user&.send_password_reset_instructions

      render json: { message: "If the email exists in our system, you will receive password reset instructions shortly." }
    end

    def reset_password
      user = User.find_by(email: reset_password_params[:email].to_s.downcase.strip)

      unless user&.valid_reset_password_token?(reset_password_params[:token])
        return render json: { errors: [ "Invalid or expired password reset token" ] }, status: :unprocessable_entity
      end

      unless user.update(password: reset_password_params[:password], password_confirmation: reset_password_params[:password_confirmation])
        return render json: { errors: user.errors.full_messages }, status: :unprocessable_entity
      end

      user.clear_reset_password_token!
      render json: { message: "Password updated successfully. Please sign in." }
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
                                           :display_name, :bio, :location, :avatar_url, :terms_accepted)
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

    def forgot_password_params
      params.require(:user).permit(:email)
    end

    def reset_password_params
      params.require(:user).permit(:email, :token, :password, :password_confirmation)
    end

    def google_auth_params
      params.permit(:credential, :terms_accepted)
    end
  end
end
