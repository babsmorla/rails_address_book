class UserMailer < ApplicationMailer
  layout "mailer"

def forgot_password(user)
  @user = user
  # Pass the token as the first argument (which Rails treats as the :id)
  @url = edit_password_reset_url(@user.reset_password_token)
  mail(to: @user.email, subject: "Reset your password")
end

end
