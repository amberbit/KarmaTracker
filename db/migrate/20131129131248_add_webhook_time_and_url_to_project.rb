class AddWebhookTimeAndUrlToProject < ActiveRecord::Migration
  def change
    add_column :projects, :web_hook_time, :datetime
    add_column :projects, :web_hook_exists, :boolean, :default => false
  end
end
