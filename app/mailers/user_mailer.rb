class UserMailer < ActionMailer::Base

  def confirmation_email(user, host)
    @user = user
    @url = get_root_url(host) + "#/login?confirmation_token=" + @user.confirmation_token
    mail(to: @user.email, subject: 'KarmaTracker e-mail confirmation', from: 'no-reply@example.com')
  end

  def password_reset user, host, port
    @user = user
    @url =  get_root_url(host, port) + "#/edit_password_reset/#{@user.password_reset_token}"
    mail(to: @user.email, subject: 'KarmaTracker password reset', from: 'no-reply@example.com')
  end

  private 
    def get_root_url host, port = nil
      root_url(host: host, port: port)
    end
end
