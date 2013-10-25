class RenameIdentityToIntegrationInIntegrationsType < ActiveRecord::Migration
  def up
    execute "UPDATE integrations SET type = 'PivotalTrackerIntegration' WHERE type = 'PivotalTrackerIdentity'"
    execute "UPDATE integrations SET type = 'GitHubIntegration' WHERE type = 'GitHubIdentity'"
  end

  def down
    execute "UPDATE integrations SET type = 'PivotalTrackerIdentity' WHERE type = 'PivotalTrackerIntegration'"
    execute "UPDATE integrations SET type = 'GitHubIdentity' WHERE type = 'GitHubIntegration'"
  end
end
