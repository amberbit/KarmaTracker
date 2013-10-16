class ChangeProjectsRefreshingColumn < ActiveRecord::Migration
  def up
    add_column :users, :refreshing, :string
    remove_column :users, :refreshing_projects
  end

  def down
    add_column :users, :refreshing_projects, :boolean, default: false
    remove_column :users, :refreshing
  end
end
