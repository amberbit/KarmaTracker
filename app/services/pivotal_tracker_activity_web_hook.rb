class PivotalTrackerActivityWebHook
  include ApplicationHelper

  def initialize project
    @project = project
  end

  def create_web_hook_request integration

    Rails.logger.info "Creating web hook for PT project #{@project.source_identifier}"
    uri ="https://www.pivotaltracker.com/services/v5/projects/#{@project.source_identifier}/webhooks"
    response = perform_request('post', uri, {"webhook_version"=>"v5","webhook_url"=>"#{AppConfig.protocol}#{AppConfig.host}/api/v1/projects/#{@project.id}/pivotal_tracker_activity_web_hook?token=#{@project.web_hook_token}"}, {'X-TrackerToken' => "#{integration.api_key}", 'Content-Type'=> 'application/json'})

    if response.code == '200'
      Rails.logger.info "Creating web hook request for PT project #{@project.source_identifier} finished successfully"
    else
      Rails.logger.error "Creating web hook request for PT project #{@project.source_identifier} failed"
    end
  end

  def process_request request
    Rails.logger.info "Processing web activit hook request for PT project #{@project.source_identifier}"
    if request.kind_of?(String)
      json = JSON.parse request
    else
      json = JSON.parse request.read
    end
    event_type = json["highlight"]
    story = json["changes"].first
    project_id = json["project"]["id"]

    source_identifier = story["id"].to_s
    task = Task.where("source_name = 'Pivotal Tracker' AND source_identifier = ?", source_identifier).first_or_initialize(source_name: 'Pivotal Tracker', source_identifier: source_identifier)
    if (task.persisted? && task.project != @project) || project_id.to_s != @project.source_identifier.to_s
      Rails.logger.error "Processing web activit hook request for PT project #{@project.source_identifier} failed"
      return false
    end
    name = story["name"]
    story_type = story["story_type"]
    current_state = story["new_values"]["current_state"]
    task.name = name if name
    task.story_type = story_type if story_type
    if current_state
      task.current_state = current_state
      task.current_task = current_state == 'started' || current_state == 'unstarted' ? true : false
    end
    task.project = @project


    if task.save
      Rails.logger.info "Processing web activit hook request for PT project #{@project.source_identifier} finished successfully"
      return true
    else
      Rails.logger.error "Processing web activit hook request for PT project #{@project.source_identifier} failed"
      return false
    end
  end
end
