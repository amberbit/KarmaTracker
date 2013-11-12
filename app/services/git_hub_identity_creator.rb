class GitHubIdentityCreator

  class << self

    if ENV['TORQUEBOX_APP_NAME']
      include TorqueBox::Messaging::Backgroundable
    else
      def background; self; end
    end

    def create_identity(api_key, user_id)
      @identity = IntegrationsFactory.new(GitHubIntegration.new, {api_key: api_key, user_id: user_id}).create
      @identity.save
    end
  end
end
