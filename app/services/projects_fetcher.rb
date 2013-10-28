require 'net/https'
require 'net/http'
require 'open-uri'

class ProjectsFetcher
  if ENV['TORQUEBOX_APP_NAME']
    include TorqueBox::Messaging::Backgroundable
  else
    def background; self; end
  end

  def fetch_all
    Rails.logger.info "Fetching projects for all users"
    User.all.each do |user|
      fetch_for_user(user)
    end
    Rails.logger.info "Successfully updated list of projects for all users"
  end

  def fetch_for_user(user)
    Rails.logger.info "Fetching projects for user #{user.id}"
    user.update_attribute('refreshing', 'projects')
    user.integrations.each do |integration|
      case integration.type
      when 'PivotalTrackerIntegration'
        PivotalTrackerProjectsFetcher.new.fetch_projects integration
      when 'GitHubIntegration'
        GitHubProjectsFetcher.new.fetch_projects integration
      end
    end
    Rails.logger.info "Successfully updated list of projects for user #{user.id}"
    user.update_attribute('refreshing', nil)
  end

  def fetch_for_project(project, integration)
    user = integration.user
    user.update_attribute('refreshing', 'tasks')
    case integration.type
    when 'PivotalTrackerIntegration'
      PivotalTrackerProjectsFetcher.new.fetch_tasks project, integration
    when 'GitHubIntegration'
      GitHubProjectsFetcher.new.fetch_tasks_for_project project, integration
    end
    integration.update_attribute('last_projects_refresh_at', DateTime.now)
    user.update_attribute('refreshing', nil)
  end

end
