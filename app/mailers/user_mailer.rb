class UserMailer < ActionMailer::Base

  def confirmation_email(user, host)
    @user = user
    @url = root_url(host: host) + "#/login?confirmation_token=" + @user.confirmation_token
    mail(to: @user.email, subject: 'KarmaTracker e-mail confirmation', from: 'no-reply@example.com')
  end

end
