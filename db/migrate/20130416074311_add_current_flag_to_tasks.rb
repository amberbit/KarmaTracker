class AddCurrentFlagToTasks < ActiveRecord::Migration
  def change
    add_column :tasks, :current_task, :boolean, :default => false
  end
end
