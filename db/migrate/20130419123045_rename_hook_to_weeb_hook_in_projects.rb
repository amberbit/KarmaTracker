class RenameHookToWeebHookInProjects < ActiveRecord::Migration
  def change
    rename_column :projects, :hook, :web_hook
  end
end
