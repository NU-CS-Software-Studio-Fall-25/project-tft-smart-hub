class UserMailer < ApplicationMailer
  def verification_email
    @user = params[:user]
    @verification_token = @user.email_verification_token

    mail to: @user.email, subject: "Verify your TFT Smart Hub account"
  end
end
