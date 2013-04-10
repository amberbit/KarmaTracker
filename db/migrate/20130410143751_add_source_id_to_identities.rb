class AddSourceIdToIdentities < ActiveRecord::Migration
  def up
    add_column :identities, :source_id, :string, :null => false
  end

  def down
    remove_column :identities, :source_id
  end
end
