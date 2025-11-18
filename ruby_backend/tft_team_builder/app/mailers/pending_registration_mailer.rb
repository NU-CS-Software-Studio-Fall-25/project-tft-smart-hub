class PendingRegistrationMailer < ApplicationMailer
  def verification_email
    @pending = params[:pending]
    @verification_code = @pending.verification_code
    
    # Use Resend to send email
    resend_client = Resend::Client.new
    
    html_body = ApplicationController.render(
      template: 'pending_registration_mailer/verification_email',
      layout: 'mailer',
      assigns: { pending: @pending, verification_code: @verification_code }
    )
    
    text_body = ApplicationController.render(
      template: 'pending_registration_mailer/verification_email.text',
      layout: false,
      assigns: { pending: @pending, verification_code: @verification_code }
    )
    
    resend_client.emails.send({
      from: ENV.fetch('RESEND_FROM_EMAIL', 'onboarding@resend.dev'),
      to: @pending.email,
      subject: "Verify your TFT Smart Hub account - Code: #{@verification_code}",
      html: html_body,
      text: text_body
    })
  end
end
