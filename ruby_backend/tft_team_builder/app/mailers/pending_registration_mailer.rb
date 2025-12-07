class PendingRegistrationMailer < ApplicationMailer
  def verification_email
    @pending = params[:pending]
    @verification_code = @pending.verification_code

    # Use Resend API directly (official way)
    Resend.api_key = ENV.fetch("RESEND_API_KEY", "test_key")

    html_body = <<~HTML
      <!DOCTYPE html>
      <html>
        <head>
          <meta charset="utf-8">
          <style>
            body { font-family: Arial, sans-serif; line-height: 1.6; color: #333; max-width: 600px; margin: 0 auto; padding: 20px; }
            .header { background: linear-gradient(135deg, #667eea 0%, #764ba2 100%); color: white; padding: 30px; text-align: center; border-radius: 10px 10px 0 0; }
            .content { background: #f9f9f9; padding: 30px; border-radius: 0 0 10px 10px; }
            .code-box { background: white; border: 2px solid #667eea; border-radius: 8px; padding: 20px; text-align: center; margin: 20px 0; }
            .code { font-size: 32px; font-weight: bold; letter-spacing: 8px; color: #667eea; }
            .warning { color: #e74c3c; font-size: 14px; margin-top: 20px; }
          </style>
        </head>
        <body>
          <div class="header">
            <h1>🎮 TFT Smart Hub</h1>
            <p>Email Verification</p>
          </div>
          <div class="content">
            <h2>Welcome!</h2>
            <p>Thank you for registering. Please use the verification code below to complete your registration:</p>
            <div class="code-box">
              <div class="code">#{@verification_code}</div>
            </div>
            <p>Enter this code on the registration page to verify your email address.</p>
            <p class="warning">⚠️ This code will expire in 2 hours.</p>
            <p>If you didn't request this code, please ignore this email.</p>
          </div>
        </body>
      </html>
    HTML

    begin
      Resend::Emails.send({
        from: "onboarding@resend.dev",
        to: @pending.email,
        subject: "Verify your TFT Smart Hub account - Code: #{@verification_code}",
        html: html_body
      })
      Rails.logger.info("Verification email sent successfully to #{@pending.email}")
    rescue StandardError => e
      Rails.logger.error("Failed to send verification email: #{e.message}")
      raise e
    end
  end
end
