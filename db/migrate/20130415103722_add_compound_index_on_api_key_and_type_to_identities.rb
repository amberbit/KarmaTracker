class AddCompoundIndexOnApiKeyAndTypeToIdentities < ActiveRecord::Migration
  def change
    add_index :identities, [:api_key, :type], :unique => true
  end
end
