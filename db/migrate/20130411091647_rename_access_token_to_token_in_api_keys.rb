class RenameAccessTokenToTokenInApiKeys < ActiveRecord::Migration
  def up
    rename_column :api_keys, :access_token, :token
  end

  def down
    rename_column :api_keys, :token, :access_token
  end
end
