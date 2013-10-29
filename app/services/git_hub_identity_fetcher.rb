class GitHubIdentityFetcher
  include ApplicationHelper

  if ENV['TORQUEBOX_APP_NAME']
    include TorqueBox::Messaging::Backgroundable
  else
    def background; self; end
  end

  def fetch_for_user(code)
    Rails.logger.info "Fetching identities for GH user: "
    fetch_access_token(code)
    #uri = "https://api.github.com/user/subscriptions"

    #begin
      #response = perform_request('get', uri, {}, {'Authorization' => "token #{identity.api_key}"})
      #uri = extract_next_link(response)
      #repos = JSON.parse(response.body)
      #if repos.instance_of?(Array)

        #repos.each do |repo|
          #repo_name = repo['name']
          #owner_name = repo['owner']['login']
          #name = repo['full_name']
          #source_identifier = repo['id'].to_s

          #project = Project.where("source_name = 'GitHub' AND source_identifier = ?", source_identifier).
            #first_or_initialize(source_name: 'GitHub', source_identifier: source_identifier)
          #project.name = name
          #project.save
          #fetch_identities project, identity, repo_name, owner_name
          #GitHubWebHooksManager.new({project: project}).create_hook(identity) unless project.web_hook
        #end
      #else
        #if repos.instance_of?(Hash) && repos['message'] == 'Bad credentials'
          #UserMailer.invalid_api_key(identity).deliver
        #end
        #break
      #end
    #end while uri

    #Rails.logger.info "Successfully updated list of projects for GH identity #{identity.api_key}"
  end

  private
    def fetch_access_token(code)
      Rails.logger.info "Fetching access token"
      uri = "https://github.com/login/oauth/access_token"
      begin
        request_hash = { client_id: AppConfig.github_api.client_id,
                         client_secret: AppConfig.github_api.secret,
                         redirect_uri: "http://localhost:3000/auth/github/callback/identity",
                         code: code }

        response = perform_request('post', uri, request_hash, { 'Accept' => 'application/json'})
      rescue Exception => ex
      end
    end
end
