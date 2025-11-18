# Preview all emails at http://localhost:3000/rails/mailers/pending_registration_mailer
class PendingRegistrationMailerPreview < ActionMailer::Preview
  # Preview this email at http://localhost:3000/rails/mailers/pending_registration_mailer/verification_email
  def verification_email
    PendingRegistrationMailer.verification_email
  end
end
