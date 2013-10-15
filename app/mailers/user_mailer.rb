class UserMailer < ActionMailer::Base

  def confirmation_email(user, host)
    @user = user
    @url = get_root_url(host) + "#/login?confirmation_token=" + @user.confirmation_token
    mail(to: @user.email, subject: 'KarmaTracker e-mail confirmation', from: 'no-reply@example.com')
  end

  def password_reset user, host
    @user = user
    @url =  get_root_url(host) + "#/edit_password_reset/#{@user.password_reset_token}"
    mail(to: @user.email, subject: 'KarmaTracker password reset', from: 'no-reply@example.com')
  end

  def invalid_api_key identity
    @service = identity.type
    @api_key = identity.api_key
    mail(to: identity.user.email, subject: 'KarmaTracker import failed. Invalid API key', from: 'no-reply@example.com')
  end

  def account_created(user, host, provider, password)
    @user = user
    @url = get_root_url(host)
    @provider = provider
    @password = password
    mail(to: @user.email, subject: 'KarmaTracker account created', from: 'no-reply@example.com')
  end

  private 
    def get_root_url host
      root_url(host: host)
    end
end
