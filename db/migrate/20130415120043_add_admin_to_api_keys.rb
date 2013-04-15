class AddAdminToApiKeys < ActiveRecord::Migration
  def up
    add_column :api_keys, :admin, :boolean, default: false
  end

  def down
    remove_column :api_keys, :admin
  end
end
