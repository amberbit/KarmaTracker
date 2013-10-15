OmniAuth.config.logger = Rails.logger

Rails.application.config.middleware.use OmniAuth::Builder do
  provider :google_oauth2, AppConfig.google_api.client_id, AppConfig.google_api.secret, {
    redirect_uri: AppConfig.google_api.callback_url,
    name: "google",
    prompt: '',
    access_type: 'online'
  }

  provider :github, AppConfig.github_api.client_id, AppConfig.github_api.secret, scope: "user:email"
end

OmniAuth.config.on_failure = Proc.new { |env|
  OmniAuth::FailureEndpoint.new(env).redirect_to_failure
}
