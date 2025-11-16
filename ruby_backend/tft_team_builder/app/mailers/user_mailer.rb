class UserMailer < ApplicationMailer
  def verification_email
    @user = params[:user]
    @verification_token = @user.email_verification_token
    @verification_url = login_magic_link(mode: "verify", token: @verification_token)

    mail to: @user.email, subject: "Verify your TFT Smart Hub account"
  end

  def password_reset_email
    @user = params[:user]
    @reset_token = @user.reset_password_token
    @reset_url = login_magic_link(mode: "reset", token: @reset_token)

    mail to: @user.email, subject: "Reset your TFT Smart Hub password"
  end

  private

  def login_magic_link(mode:, token:)
    base = ENV.fetch("FRONTEND_BASE_URL", "http://localhost:5173")
    uri = URI.parse(base)
    uri.path = "/login"
    existing = Rack::Utils.parse_query(uri.query.to_s)
    merged = existing.merge("mode" => mode, "email" => @user.email, "token" => token)
    uri.query = merged.to_query
    uri.to_s
  end
end
