class AddHookToProjects < ActiveRecord::Migration
  def change
    add_column :projects, :hook, :string, default: nil
  end
end
