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
    user.update_attribute('refreshing_projects', true)
    user.identities.each do |identity|
      case identity.type
          when 'PivotalTrackerIdentity'
            PivotalTrackerProjectsFetcher.new.fetch_projects identity
          when 'GitHubIdentity'
            GitHubProjectsFetcher.new.fetch_projects identity
        end
    end
    Rails.logger.info "Successfully updated list of projects for user #{user.id}"
    user.update_attribute('refreshing_projects', false)
  end

  def fetch_for_project(project, identity)
    user = identity.user
    user.update_attribute('refreshing_projects', true)
    case identity.type
      when 'PivotalTrackerIdentity'
        PivotalTrackerProjectsFetcher.new.fetch_tasks project, identity
      when 'GitHubIdentity'
        GitHubProjectsFetcher.new.fetch_tasks_for_project project, identity
    end
    identity.update_attribute('last_projects_refresh_at', DateTime.now)
    user.update_attribute('refreshing_projects', false)
  end

end
