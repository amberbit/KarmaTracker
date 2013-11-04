class GitHubProjectsFetcher
  include ApplicationHelper

  def fetch_projects(integration)
    Rails.logger.info "Fetching projects for GH integration #{integration.api_key}"
    uri = "https://api.github.com/user/subscriptions"

    begin
      response = perform_request('get', uri, {}, {'Authorization' => "token #{integration.api_key}"})
      uri = extract_next_link(response)
      repos = JSON.parse(response.body)
      if repos.instance_of?(Array)

        repos.each do |repo|
          repo_name = repo['name']
          owner_name = repo['owner']['login']
          name = repo['full_name']
          source_identifier = repo['id'].to_s

          project = Project.where("source_name = 'GitHub' AND source_identifier = ?", source_identifier).
            first_or_initialize(source_name: 'GitHub', source_identifier: source_identifier)
          project.name = name
          allow_local_connect if Rails.env.test?
          project.save
          fetch_integrations project, integration, repo_name, owner_name
          GitHubWebHooksManager.new({project: project}).create_hook(integration) unless project.web_hook
        end
      else
        if repos.instance_of?(Hash) && repos['message'] == 'Bad credentials'
          UserMailer.invalid_api_key(integration).deliver
        end
        break
      end
    end while uri

    Rails.logger.info "Successfully updated list of projects for GH integration #{integration.api_key}"
  end

  def fetch_integrations(project, integration, repo_name, repo_owner)
    Rails.logger.info "Fetching integrations for GH project #{project.source_identifier}"
    integrations = []
    uri = "https://api.github.com/repos/#{repo_owner}/#{repo_name}/collaborators"

    begin
      response = perform_request('get', uri, {}, {'Authorization' => "token #{integration.api_key}"})
      uri = extract_next_link(response)
      collaborators = JSON.parse(response.body)
      break unless collaborators.instance_of?(Array)

      collaborators.each do |collaborator|
        next unless collaborator['login']
        gh_integration = GitHubIntegration.find_by_source_id(collaborator['login'])
        integrations << gh_integration if gh_integration.present?
      end
    end while uri

    integrations.each do |id|
      project.integrations << id unless project.integrations.include?(id)
    end

    project.integrations.each do |id|
      project.integrations.delete(id) unless integrations.include?(id)
    end
    Rails.logger.info "Successfully updated list of integrations for GH project #{project.source_identifier}"
  end

  def fetch_tasks(project, integration, repo_name, repo_owner, state)
    Rails.logger.info "Fetching tasks for GH project #{project.source_identifier}"
    uri = "https://api.github.com/repos/#{repo_owner}/#{repo_name}/issues?state=#{state}"

    begin
      response = perform_request('get', uri, {}, {'Authorization' => "token #{integration.api_key}"})
      uri = extract_next_link(response)
      issues = JSON.parse(response.body)
      break unless issues.instance_of?(Array)

      issues.each do |issue|
        name = issue['title']
        source_identifier = "#{project.source_identifier}/#{issue["number"]}"
        story_type = 'issue'
        current_state = state

        task = Task.where("source_name = 'GitHub' AND source_identifier = ?", source_identifier).
          first_or_initialize(source_name: 'GitHub', source_identifier: source_identifier)
        task.name = name
        task.story_type = story_type
        task.current_state = current_state
        task.current_task = (current_state == 'open' ? true : false)
        task.project = project
        task.save
      end
    end while uri

    Rails.logger.info "Successfully updated list of tasks for GH project #{project.source_identifier}"
  rescue
    Rails.logger.error "Couldn't fetch issues for GitHub repositry #{repo_owner}/#{repo_name} (#{project.source_identifier})"
  end
  
  def fetch_tasks_for_project(project, integration)
    Rails.logger.info "Fetching project data for GH project #{project.source_identifier}"
    uri = "https://api.github.com/user/subscriptions"

    begin
      response = perform_request('get', uri, {}, {'Authorization' => "token #{integration.api_key}"})
      uri = extract_next_link(response)
      repos = JSON.parse(response.body)
      if repos.instance_of?(Array)
        repo = repos.find { |repo| repo['id'].to_s == project.source_identifier }
        fetch_tasks(project, integration, repo['name'], repo['owner']['login'], 'open')
        fetch_tasks(project, integration, repo['name'], repo['owner']['login'], 'closed')
      else
        if repos.instance_of?(Hash) && repos['message'] == 'Bad credentials'
          UserMailer.invalid_api_key(integration).deliver
        end
        break
      end
    end while uri

    Rails.logger.info "Successfully fetched project data for GH integration #{integration.api_key} and project #{project.source_identifier}"
  end

  private

  def extract_next_link response
    if(response.get_fields('link'))
      tmp = response.get_fields('link').first.split(',').select{|link|
        link.split(';').last =~ /next/i
      }.first
      tmp.match(/<.*>/).to_s.gsub(/[<>]/, '') if tmp
    else
      nil
    end
  end

end
