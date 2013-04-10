require 'net/http'
require 'net/https'
require 'open-uri'

class ProjectsFetcher

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
  end

  private

  def fetch_from_pivotal_tracker(identity)
    uri = "https://www.pivotaltracker.com/services/v4/projects"
    doc = Nokogiri::XML(open(uri, 'X-TrackerToken' => identity.api_key))

    projects = doc.xpath('//project').each do |project|
      details = {
        name: project.xpath('./name').first.content,
        source_identifier: project.xpath('./id').first.content
      }

      unless project_already_exists?('PT', details[:source_identifier])
        Project.create(details.merge({source_name: 'PT'}))
      end
    end
  end

  def project_already_exists?(source_id, source_name)
    Project.where('source_name = ? AND source_identifier = ?', source_name, source_id).count > 0
  end
end
