class ProjectsRefresher

  def run
    Identity.find_each do |identity|
      unless identity.last_projects_refresh_at.present? && identity.last_projects_refresh_at > (DateTime.now - AppConfig.projects_refresh_period.hours)
        case identity.type
          when 'PivotalTrackerIdentity'
            PivotalTrackerProjectsFetcher.new.fetch_projects identity
            identity.projects do |project|
              PivotalTrackerProjectsFetcher.new.fetch_tasks project, identity unless project.updated_at.present? && project.updated_at > (DateTime.now - AppConfig.projects_refresh_period.hours)
            end
          when 'GitHubIdentity'
            GitHubProjectsFetcher.new.fetch_projects identity
            identity.projects do |project|
              GitHubProjectsFetcher.new.fetch_tasks_for_project project, identity unless project.updated_at.present? && project.updated_at > (DateTime.now - AppConfig.projects_refresh_period.hours)
            end 
        end
        identity.update_attribute('last_projects_refresh_at', DateTime.now)
      end
    end
  end
  
end

