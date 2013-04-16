class ExtendTaskTitleSize < ActiveRecord::Migration
  def up
    change_column :tasks, :name, :text, :null => false
  end

  def down
    change_column :tasks, :name, :string, :null => false
  end
end
