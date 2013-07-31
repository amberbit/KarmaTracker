class AddRefreshingProjectsFlagToUser < ActiveRecord::Migration
  def change
    add_column :users, :refreshing_projects, :boolean, default: false
  end
end
