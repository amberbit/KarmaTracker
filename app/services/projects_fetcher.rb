require 'net/http'
require 'net/https'
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

    projects = doc.xpath('//project').each do |data|
      name = data.xpath('./name').first.content
      source_identifier = data.xpath('./id').first.content

      project = Project.where("source_name = 'Pivotal Tracker' AND source_identifier = ?", source_identifier).
        first_or_initialize(source_name: 'Pivotal Tracker', source_identifier: source_identifier)
      project.name = name
      project.save

      fetch_identities_for_project project, data
    end
  end

  def fetch_identities_for_project(project, data)
    data.xpath('./memberships/membership/id').each do |pt_id|
      identity = PivotalTrackerIdentity.find_by_source_id(pt_id.content)
      project.identities << identity if identity.present?
    end
  end
end
