class PivotalTrackerActivityWebHook
  include ApplicationHelper

  def initialize project
    @project = project
  end

  def get_web_hook_integration integration
    if @project.web_hook_exists && @project.web_hook_time > DateTime.now - AppConfig.webhook_check_time
      return true
    elsif @project.web_hook_time.nil? || @project.web_hook_time < DateTime.now - AppConfig.webhook_check_time
      Rails.logger.info "Getting web hook for PT project #{@project.source_identifier}"
      @project.update_attributes(:web_hook_time => DateTime.now)

      web_hook_url = "#{AppConfig.protocol}#{AppConfig.host}/api/v1/projects/#{@project.id}/pivotal_tracker_activity_web_hook?token=#{@project.web_hook_token}"
      uri ="https://www.pivotaltracker.com/services/v5/projects/#{@project.source_identifier}/webhooks"

      response = perform_request('get', uri, {}, {'X-TrackerToken' => "#{integration.api_key}", 'Content-Type'=> 'application/json'})
      json = JSON.parse response.body
      if response.code == '200' && json.any? { |web_hook| web_hook["webhook_url"] == web_hook_url }
        Rails.logger.info "Checking web hook existing for PT project #{@project.source_identifier} finished successfully"
        @project.update_attributes(:web_hook_exists => true)
        return true
      else
        Rails.logger.error "Confirm existing for PT project #{@project.source_identifier} failed"
        return false
      end
    else
      return false
    end
  end

  def create_web_hook_request integration
    Rails.logger.info "Creating web hook for PT project #{@project.source_identifier}"
    uri ="https://www.pivotaltracker.com/services/v5/projects/#{@project.source_identifier}/webhooks"
    response = perform_request('post', uri, {"webhook_version"=>"v5","webhook_url"=>"#{AppConfig.protocol}#{AppConfig.host}/api/v1/projects/#{@project.id}/pivotal_tracker_activity_web_hook?token=#{@project.web_hook_token}"}, {'X-TrackerToken' => "#{integration.api_key}", 'Content-Type'=> 'application/json'})

    if response.code == '200'
      json = JSON.parse response.body
      @project.update_attributes(:web_hook_time => DateTime.now, :web_hook_exists => true)
      Rails.logger.info "Creating web hook request for PT project #{@project.source_identifier} finished successfully"
      return true
    else
      Rails.logger.error "Creating web hook request for PT project #{@project.source_identifier} failed"
      @project.update_attributes(:web_hook_time => DateTime.now)
      return false
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
    story_changes = json["changes"].first
    project_id = json["project"]["id"]

    source_identifier = story_changes["id"].to_s
    task = Task.where("source_name = 'Pivotal Tracker' AND source_identifier = ?", source_identifier).first_or_initialize(source_name: 'Pivotal Tracker', source_identifier: source_identifier)
    if (task.persisted? && task.project != @project) || project_id.to_s != @project.source_identifier.to_s
      Rails.logger.error "Processing web activit hook request for PT project #{@project.source_identifier} failed"
      return false
    end
    name = story_changes["name"]
    story_type = story_changes["story_type"]
    current_state = story_changes["new_values"]["current_state"]
    after_task = story_changes["new_values"]["after_id"]
    before_task = story_changes["new_values"]["before_id"]

    task.name = name if name
    task.story_type = story_type if story_type
    if current_state
      task.current_state = current_state
      task.current_task = current_state == 'started' || current_state == 'unstarted' ? true : false
    end
    task.project = @project

    if after_task
      after_task_position = @project.tasks.find_by_source_identifier(after_task.to_s).position
      task.insert_at(after_task_position+1) if task.position.nil? || task.position > after_task_position
      task.insert_at(after_task_position) if task.position.present? && task.position < after_task_position
    elsif before_task && !after_task
      task.move_to_top
    else
      task.insert_at(1)
    end

    if task.save
      Rails.logger.info "Processing web activit hook request for PT project #{@project.source_identifier} finished successfully"
      return true
    else
      Rails.logger.error "Processing web activit hook request for PT project #{@project.source_identifier} failed"
      return false
    end
  end
end
