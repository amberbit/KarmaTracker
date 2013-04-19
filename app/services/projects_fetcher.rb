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
    user.identities.each do |identity|
      fetch_for_identity(identity)
    end
    Rails.logger.info "Successfully updated list of projects for user #{user.id}"
  end

  def fetch_for_identity(identity)
    case identity.type
      when 'PivotalTrackerIdentity'
        PivotalTrackerProjectsFetcher.new.fetch_projects identity
      when 'GitHubIdentity'
        GitHubProjectsFetcher.new.fetch_projects identity
    end
    identity.update_attribute('last_projects_refresh_at', DateTime.now)
  end
end
