class AddFieldsToTasks < ActiveRecord::Migration
  def change
    add_column :tasks, :name, :string, :null => false
    add_column :tasks, :source_name, :string, :null => false
    add_column :tasks, :source_identifier, :string, :null => false
    add_column :tasks, :current_state, :string, :null => false
    add_column :tasks, :story_type, :string, :null => false

    add_index :tasks, [:source_name, :source_identifier], :unique => true
  end
end
