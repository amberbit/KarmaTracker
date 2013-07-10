class UserMailer < ActionMailer::Base

  def confirmation_email(user, host)
    @user = user
    @url = root_url(host: host) + "#/login?confirmation_token=" + @user.confirmation_token
    mail(to: @user.email, subject: 'KarmaTracker e-mail confirmation', from: 'no-reply@example.com')
  end

  def password_reset user, host, port
    @user = user
    @url = root_url(host: host, port: port) + "#/edit_password_reset/#{@user.password_reset_token}"
    mail(to: @user.email, subject: 'KarmaTracker password reset', from: 'no-reply@example.com')
  end
end
