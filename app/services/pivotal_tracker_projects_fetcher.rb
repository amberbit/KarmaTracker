class PivotalTrackerProjectsFetcher

  def fetch_projects(integration)
    within_tmp do
      Rails.logger.info "Fetching projects for PT integration #{integration.api_key}"
      uri = "https://www.pivotaltracker.com/services/v4/projects"
      begin
        open(uri, 'X-TrackerToken' => integration.api_key) do |file|
          doc = Nokogiri::XML file

          doc.xpath('//project').each do |data|
            name = data.xpath('./name').first.content
            source_identifier = data.xpath('./id').first.content

            project = Project.where("source_name = 'Pivotal Tracker' AND source_identifier = ?", source_identifier).
              first_or_initialize(source_name: 'Pivotal Tracker', source_identifier: source_identifier)
            project.name = name
            project.save

            fetch_integrations project, data
          end
        end
        Rails.logger.info "Successfully updated list of projects for PT integration #{integration.api_key}"
      rescue OpenURI::HTTPError => e
        UserMailer.invalid_api_key(integration).deliver
        Rails.logger.error "Error fetching projects from PT - #{e.message}. Check API key correctness."
      end
    end
  end

  def fetch_integrations(project, data)
    within_tmp do
      Rails.logger.info "Fetching integrations for PT project #{project.source_identifier}"
      integrations = []
      data.xpath('./memberships/membership').each do |membership|
        pt_id = membership.xpath('./member/person/id').first.content
        integration = PivotalTrackerIntegration.find_by_source_id(pt_id)
        integrations << integration if integration.present?
      end

      integrations.each do |integration|
        project.integrations << integration unless project.integrations.include?(integration)
      end

      project.integrations.each do |integration|
        project.integrations.delete(integration) unless integrations.include?(integration)
      end
      Rails.logger.info "Successfully updated list of integrations for PT project #{project.source_identifier}"
    end
  end

  def fetch_tasks(project, integration)
    within_tmp do
      Rails.logger.info "Fetching tasks for PT project #{project.source_identifier}"
      uri = "https://www.pivotaltracker.com/services/v4/projects/#{project.source_identifier}/stories"
      open(uri, 'X-TrackerToken' => integration.api_key) do |file|
        doc = Nokogiri::XML file

        doc.xpath('//story').each do |data|
          name = data.xpath('./name').first.content
          source_identifier = data.xpath('./id').first.content
          story_type = data.xpath('./story_type').first.content
          current_state = data.xpath('./current_state').first.content

          task = Task.where("source_name = 'Pivotal Tracker' AND source_identifier = ?", source_identifier).
            first_or_initialize(source_name: 'Pivotal Tracker', source_identifier: source_identifier)
          task.name = name
          task.story_type = story_type
          task.current_state = current_state
          task.project = project
          task.save
        end
      end
      fetch_current_tasks project, integration
      Rails.logger.info "Successfully updated list of tasks for PT project #{project.source_identifier}"
    end
  end

  def fetch_current_tasks(project, integration)
    within_tmp do
      Rails.logger.info "Fetching current tasks for PT project #{project.source_identifier}"
      uri = "https://www.pivotaltracker.com/services/v4/projects/#{project.source_identifier}/iterations/current"
      open(uri, 'X-TrackerToken' => integration.api_key) do |file|
        doc = Nokogiri::XML(file)

        current_tasks_ids = []
        doc.xpath('/iterations/iteration').first.xpath('./stories/story').each do |story|
          story_id = story.xpath('./id').first.content
          current_tasks_ids << story_id
        end
        project.tasks.where('source_identifier NOT IN (?)', current_tasks_ids).update_all('current_task = FALSE')
        project.tasks.where('source_identifier IN (?)', current_tasks_ids).update_all('current_task = TRUE')
      end

      Rails.logger.info "Successfully updated list of current tasks for PT project #{project.source_identifier}"
    end
  end

  private

  def within_tmp
    Dir.chdir(Rails.root.join("tmp").to_s) do
      yield
    end
  end
end
