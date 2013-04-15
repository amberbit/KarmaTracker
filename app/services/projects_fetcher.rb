require 'net/https'
require 'net/http'
require 'open-uri'

class ProjectsFetcher
  include TorqueBox::Messaging::Backgroundable

  def fetch_all
    User.all.each do |user|
      fetch_for_user(user)
    end
  end

  def fetch_for_user(user)
    user.identities.each do |identity|
      fetch_for_identity(identity)
    end
  end

  def fetch_for_identity(identity)
    case identity.type
      when 'PivotalTrackerIdentity'
        fetch_from_pivotal_tracker(identity)
    end
    identity.update_attribute('last_projects_refresh_at', DateTime.now)
  end

  private

  def fetch_from_pivotal_tracker(identity)
    uri = "https://www.pivotaltracker.com/services/v4/projects"
    doc = Nokogiri::XML(open(uri, 'X-TrackerToken' => identity.api_key))

    doc.xpath('//project').each do |data|
      name = data.xpath('./name').first.content
      source_identifier = data.xpath('./id').first.content

      project = Project.where("source_name = 'Pivotal Tracker' AND source_identifier = ?", source_identifier).
        first_or_initialize(source_name: 'Pivotal Tracker', source_identifier: source_identifier)
      project.name = name
      project.save

      fetch_identities_for_pt_project project, data
      fetch_tasks_for_pt_project project, identity
    end
  end

  def fetch_identities_for_pt_project(project, data)
    data.xpath('./memberships/membership/id').each do |pt_id|
      identity = PivotalTrackerIdentity.find_by_source_id(pt_id.content)
      project.identities << identity if identity.present? && !project.identities.include?(identity)
    end
  end

  def fetch_tasks_for_pt_project(project, identity)
    uri = "https://www.pivotaltracker.com/services/v4/projects/#{project.source_identifier}/stories"
    doc = Nokogiri::XML(open(uri, 'X-TrackerToken' => identity.api_key))

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
end
