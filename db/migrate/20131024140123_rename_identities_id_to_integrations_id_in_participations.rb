class RenameIdentitiesIdToIntegrationsIdInParticipations < ActiveRecord::Migration
  def up
    rename_column :participations, :identity_id, :integration_id
  end

  def down
    rename_column :participations, :integration_id, :identity_id
  end
end
