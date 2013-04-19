class PivotalTrackerActivityWebHook
  def initialize project
    @project = project
  end

  def process_request req
    Rails.logger.info "Processing web activit hook request for PT project #{@project.source_identifier}"
    doc = Nokogiri::XML(req)
    activity = doc.xpath('/activity').first
    event_type = activity.xpath('./event_type').first.content
    project_id = activity.xpath('./project_id').first.content
    story = activity.xpath('./stories/story').first
    source_identifier = story.xpath('./id').first.content
    task = Task.where("source_name = 'Pivotal Tracker' AND source_identifier = ?", source_identifier).
      first_or_initialize(source_name: 'Pivotal Tracker', source_identifier: source_identifier)
    if (task.persisted? && task.project != @project) || project_id.to_s != @project.source_identifier.to_s
      Rails.logger.error "Processing web activit hook request for PT project #{@project.source_identifier} failed"
      return false
    end

    name = story.xpath('./name').first
    story_type = story.xpath('./story_type').first
    current_state = story.xpath('./current_state').first

    task.name = name.content if name
    task.story_type = story_type.content if story_type
    task.current_state = current_state.content if current_state
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
