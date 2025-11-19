# frozen_string_literal: true

module Api
  class AuthController < BaseController

    def register
      # 检查邮箱是否已被注册
      if User.exists?(email: register_params[:email].to_s.downcase.strip)
        return render json: { errors: ["Email has already been taken"] }, status: :unprocessable_entity
      end
      
      # 删除该邮箱的旧待验证记录
      PendingRegistration.where(email: register_params[:email].to_s.downcase.strip).destroy_all
      
      # 创建待验证的注册记录（不是真正的用户账户）
      pending = PendingRegistration.new(
        email: register_params[:email],
        password: register_params[:password],
        password_confirmation: register_params[:password_confirmation],
        display_name: register_params[:display_name]
      )

      if pending.save
        # 发送验证码邮件
        begin
          PendingRegistrationMailer.with(pending: pending).verification_email.deliver_now
        rescue StandardError => e
          Rails.logger.error("Failed to send verification email: #{e.message}")
        end

        render json: { 
          message: "Verification code sent! Please check your email and enter the code to complete registration.",
          email: pending.email
        }, status: :created
      else
        render json: { errors: pending.errors.full_messages }, status: :unprocessable_entity
      end
    end

    def verify_email
      email = verify_email_params[:email].to_s.downcase.strip
      code = verify_email_params[:token]
      
      pending = PendingRegistration.valid_codes.find_by(email: email)
      
      if pending.nil?
        return render json: { errors: ["No pending registration found or code expired"] }, status: :unprocessable_entity
      end
      
      if pending.verify_code(code)
        begin
          # 验证成功，创建真正的用户账户
          user = pending.create_user!
          render json: auth_payload(user)
        rescue ActiveRecord::RecordInvalid => e
          render json: { errors: [e.message] }, status: :unprocessable_entity
        end
      else
        render json: { errors: ["Invalid verification code"] }, status: :unprocessable_entity
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
        render json: { errors: ["No pending registration found or registration expired"] }, status: :not_found
      end
    end

    def login
      user = User.find_by(email: login_params[:email].to_s.downcase.strip)

      if user&.authenticate(login_params[:password])
        unless user.email_verified?
          return render json: { 
            errors: ["Please verify your email before logging in. Check your inbox for the verification code."],
            email_not_verified: true,
            email: user.email
          }, status: :unauthorized
        end
        render json: auth_payload(user)
      else
        render_unauthorized("Invalid email or password")
      end
    end

    def google_auth
      token = google_auth_params[:credential]
      
      begin
        # Verify the Google ID token
        validator = GoogleIDToken::Validator.new
        payload = validator.check(token, ENV['GOOGLE_CLIENT_ID'])
        
        unless payload
          return render json: { errors: ["Invalid Google token"] }, status: :unauthorized
        end
        
        # Create or find user from Google OAuth
        user = User.from_google_oauth(payload)
        
        if user.persisted?
          render json: auth_payload(user)
        else
          render json: { errors: user.errors.full_messages }, status: :unprocessable_entity
        end
      rescue GoogleIDToken::ValidationError => e
        render json: { errors: ["Google authentication failed: #{e.message}"] }, status: :unauthorized
      rescue StandardError => e
        Rails.logger.error("Google OAuth error: #{e.message}")
        render json: { errors: ["Authentication failed"] }, status: :internal_server_error
      end
    end

    def me
      return render_unauthorized unless current_user

      render json: { user: serialize_user(current_user) }
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
        return render json: { errors: ["Invalid or expired password reset token"] }, status: :unprocessable_entity
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

    def forgot_password_params
      params.require(:user).permit(:email)
    end

    def reset_password_params
      params.require(:user).permit(:email, :token, :password, :password_confirmation)
    end

    def google_auth_params
      params.permit(:credential)
    end
  end
end
