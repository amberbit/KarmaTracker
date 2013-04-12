class AddLastProjectsRefreshAtToIdentity < ActiveRecord::Migration
  def change
    add_column :identities, :last_projects_refresh_at, :datetime
  end
end
