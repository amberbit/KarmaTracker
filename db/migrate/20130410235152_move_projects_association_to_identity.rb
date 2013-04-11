class MoveProjectsAssociationToIdentity < ActiveRecord::Migration
  def up
    rename_column :participations, :user_id, :identity_id
  end

  def down
    rename_column :participations, :identity_id, :user_id
  end
end
