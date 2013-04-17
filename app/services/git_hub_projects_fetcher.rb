class GitHubProjectsFetcher

  def fetch_projects(identity)
    Rails.logger.info "Fetching projects for GH identity #{identity.api_key}"
    uri = "https://api.github.com/user/repos"
    repos = JSON.parse(open(uri, 'Authorization' => "token #{identity.api_key}").read)

    repos.each do |repo|
      repo_name = repo["name"]
      owner_name = repo["owner"]["login"]
      name = repo["full_name"]
      source_identifier = repo["id"].to_s

      project = Project.where("source_name = 'GitHub' AND source_identifier = ?", source_identifier).
        first_or_initialize(source_name: 'GitHub', source_identifier: source_identifier)
      project.name = name
      project.save
      fetch_identities project, identity, repo_name, owner_name
      #fetch_tasks project, identity
    end
    Rails.logger.info "Successfully updated list of projects for GH identity #{identity.api_key}"
  end

  def fetch_identities(project, identity, repo_name, repo_owner)
    Rails.logger.info "Fetching identities for GH project #{project.source_identifier}"
    identities = []
    uri = "https://api.github.com/repos/#{repo_owner}/#{repo_name}/collaborators"
    collaborators = JSON.parse(open(uri, 'Authorization' => "token #{identity.api_key}").read)
    collaborators.each do |collaborator|
      gh_identity = GitHubIdentity.find_by_source_id(collaborator["login"])
      identities << gh_identity if gh_identity.present?
    end

    identities.each do |id|
      project.identities << id unless project.identities.include?(id)
    end

    project.identities.each do |id|
      project.identities.delete(id) unless identities.include?(id)
    end
    Rails.logger.info "Successfully updated list of identities for GH project #{project.source_identifier}"
  end

  def fetch_tasks(project, identity)
    Rails.logger.info "Fetching tasks for PT project #{project.source_identifier}"

    Rails.logger.info "Successfully updated list of tasks for PT project #{project.source_identifier}"
  end
end
