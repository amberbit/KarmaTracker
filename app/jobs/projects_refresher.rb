class ProjectsRefresher

  def run
    Integration.find_each do |integration|
      unless integration.last_projects_refresh_at.present? && integration.last_projects_refresh_at > (DateTime.now - AppConfig.projects_refresh_period.hours)
        case integration.type
          when 'PivotalTrackerIntegration'
            PivotalTrackerProjectsFetcher.new.fetch_projects integration
            integration.projects do |project|
              PivotalTrackerProjectsFetcher.new.fetch_tasks project, integration unless project.updated_at.present? && project.updated_at > (DateTime.now - AppConfig.projects_refresh_period.hours)
            end
          when 'GitHubIntegration'
            GitHubProjectsFetcher.new.fetch_projects integration
            integration.projects do |project|
              GitHubProjectsFetcher.new.fetch_tasks_for_project project, integration unless project.updated_at.present? && project.updated_at > (DateTime.now - AppConfig.projects_refresh_period.hours)
            end 
        end
        integration.update_attribute('last_projects_refresh_at', DateTime.now)
      end
    end
  end
  
end

