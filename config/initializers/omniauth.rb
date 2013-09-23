OmniAuth.config.logger = Rails.logger

Rails.application.config.middleware.use OmniAuth::Builder do
  provider :google_oauth2, AppConfig.google_api.client_id, AppConfig.google_api.secret, {
    redirect_uri: AppConfig.google_api.callback_url,
    name: "google",
    prompt: '',
    access_type: 'online'
  }
end
