class AddWebHookTokenToProject < ActiveRecord::Migration
  def change
    add_column :projects, :web_hook_token, :string
  end
end
