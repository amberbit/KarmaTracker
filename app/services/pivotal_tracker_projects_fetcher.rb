class PivotalTrackerProjectsFetcher
  include ApplicationHelper

  def fetch_projects(integration)
    Rails.logger.info "Fetching projects for PT integration #{integration.api_key}"
    uri = "https://www.pivotaltracker.com/services/v5/projects"
    begin
      response = perform_request('get', uri, {}, {'X-TrackerToken' => integration.api_key})
      uri = extract_next_link(response)
      repos = JSON.parse(response.body)
      if repos.instance_of?(Array)
        repos.each do |data|
          name = data["name"]
          source_identifier = data["id"].to_s
           project = Project.where("source_name = 'Pivotal Tracker' AND source_identifier = ?", source_identifier).
            first_or_initialize(source_name: 'Pivotal Tracker', source_identifier: source_identifier)
          project.name = name
          allow_local_connect if Rails.env.test?
          project.save

          fetch_integrations project, data, integration
        end
      end

    Rails.logger.info "Successfully updated list of projects for PT integration #{integration.api_key}"
    rescue OpenURI::HTTPError => e
      UserMailer.invalid_api_key(integration).deliver
      Rails.logger.error "Error fetching projects from PT - #{e.message}. Check API key correctness."
    end while uri
  end

  def fetch_integrations(project, data, integration)
    Rails.logger.info "Fetching integrations for PT project #{project.source_identifier}"
    uri = "https://www.pivotaltracker.com/services/v5/projects/#{project.source_identifier}/memberships"
    integrations = []
    begin
      response = perform_request('get', uri, {}, {'X-TrackerToken' => integration.api_key})
      uri = extract_next_link(response)
      repos = JSON.parse(response.body)

      if repos.instance_of?(Array)
        repos.each do |membership|
          pt_id = membership["person"]["id"].to_s
          integration = PivotalTrackerIntegration.find_by_source_id(pt_id)
          integrations << integration if integration.present?
        end
      end

    end while uri

    integrations.each do |integration|
      project.integrations << integration unless project.integrations.include?(integration)
    end

    project.integrations.each do |integration|
      project.integrations.delete(integration) unless integrations.include?(integration)
    end
    Rails.logger.info "Successfully updated list of integrations for PT project #{project.source_identifier}"
  end

   def fetch_tasks(project, integration)
    Rails.logger.info "Fetching tasks for PT project #{project.source_identifier}"
    limit = 100
    offset = 0
    begin
      uri = "https://www.pivotaltracker.com/services/v5/projects/#{project.source_identifier}/stories?limit=#{limit}&offset=#{offset}&filter=-state:accepted"
      response = perform_request('get', uri, {}, {'X-TrackerToken' => integration.api_key})
#      uri = extract_next_link(response)
      repos = JSON.parse(response.body)
      if repos.instance_of?(Array)
        repos.each_with_index do |data, index|
          name = data["name"]
          source_identifier = data["id"].to_s
          story_type = data["story_type"]
          current_state = data["current_state"]

          task = Task.where("source_name = 'Pivotal Tracker' AND source_identifier = ?", source_identifier).
            first_or_initialize(source_name: 'Pivotal Tracker', source_identifier: source_identifier)
          task.name = name
          task.story_type = story_type
          task.current_state = current_state
          task.project = project
          task.position = (index+offset+1)
          task.save
        end
      end
      offset = offset+limit
    end while repos.count == limit
    fetch_current_tasks project, integration

    Rails.logger.info "Successfully updated list of tasks for PT project #{project.source_identifier}"
  end

  def fetch_current_tasks(project, integration)
    Rails.logger.info "Fetching current tasks for PT project #{project.source_identifier}"
    uri = "https://www.pivotaltracker.com/services/v5/projects/#{project.source_identifier}/iterations?scope=current"
    begin
      response = perform_request('get', uri, {}, {'X-TrackerToken' => integration.api_key})
      uri = extract_next_link(response)
      repos = JSON.parse(response.body)
      if repos.instance_of?(Array)
        current_tasks_ids = []
        repos.each do |data|
          data["stories"].each do |story|
            story_id = story["id"].to_s
            current_tasks_ids << story_id
          end
        end
      end
      project.tasks.where('source_identifier NOT IN (?)', current_tasks_ids).update_all('current_task = FALSE')
      project.tasks.where('source_identifier IN (?)', current_tasks_ids).update_all('current_task = TRUE')
    end while uri

    Rails.logger.info "Successfully updated list of current tasks for PT project #{project.source_identifier}"
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
