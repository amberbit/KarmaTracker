class RenameIdentitiesToIntegrations < ActiveRecord::Migration
  def up
    rename_table :identities, :integrations
  end

  def down
    rename_table :integrations, :identities
  end
end
