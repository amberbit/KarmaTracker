class GitHubWebHooksManager
  include ApplicationHelper

  def initialize params={}
    @project = params[:project]
    if @project
      @repo_owner = @project.name.split('/').first
      @repo_name = @project.name.split('/').last
    end
    @request = params[:request]
  end

  def process_feed
    return nil unless @request && @request.headers['X-Github-Event'] =~ /issues/

    json = JSON.parse @request.body
    issue = json['issue']
    repository = json['repository']
    project = Project.where({source_name: 'GitHub', source_identifier: repository['id']}).first
    return nil unless project

    source_identifier = "#{repository['id']}/#{issue['number']}"
    task = Task.where("source_name = 'GitHub' AND source_identifier = ?", source_identifier).
      first_or_initialize(source_name: 'GitHub', source_identifier: source_identifier)
    task.name = issue['title']
    task.story_type = 'issue'
    task.current_state = issue['state']
    task.current_task = (issue['state'] == 'open' ? true : false)
    task.project = project
    task.save
    task
  rescue
    Rails.logger.error "Failed processing GitHub issues feed: #{@request.body}"
  end

  def create_hook identity
    Rails.logger.info "Creating hook for GitHub repositry #{@repo_owner}/#{@repo_name}"
    uri = "https://api.github.com/repos/#{@repo_owner}/#{@repo_name}/hooks"
    params = {
      active: true,
      name: 'web',
      config: {content_type: 'json', url: AppConfig.hooks.git_hub},
      events: ['issues']
    }
    response = perform_request('post', uri, params, {'Authorization' => "token #{identity.api_key}"})
    hook = JSON.parse(response.body)

    if response.code =~ /2../
      @project.update_attributes hook: hook['id']
    end
  rescue
    Rails.logger.error "Couldn't create hook for GitHub repositry #{@repo_owner}/#{@repo_name} (#{@project.source_identifier})"
  end

  def destroy_hook identity
    Rails.logger.info "Removing hook for GitHub repositry #{@repo_owner}/#{@repo_name}"
    uri = "https://api.github.com/repos/#{@repo_owner}/#{@repo_name}/hooks/#{@project.hook}"
    response = perform_request('delete', uri, {}, {'Authorization' => "token #{identity.api_key}"})

    if response.code =~ /2../
      @project.update_attributes hook: nil
    end
  rescue
    Rails.logger.error "Couldn't destroy hook for GitHub repositry #{@repo_owner}/#{@repo_name} (#{@project.source_identifier})"
  end

end
