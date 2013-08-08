class RemoveNameFromIdentities < ActiveRecord::Migration
  def change
    remove_column :identities, :name
  end
end
