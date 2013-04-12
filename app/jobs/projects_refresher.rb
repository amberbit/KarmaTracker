class ProjectsRefresher

  def run
    Identity.find_each do |identity|
      unless identity.last_projects_refresh_at.present? && identity.last_projects_refresh_at > (DateTime.now - AppConfig.projects_refresh_period.hours)
        ProjectsFetcher.new.fetch_for_identity(identity)
        identity.update_attribute('last_projects_refresh_at', DateTime.now)
      end
    end
  end

end
