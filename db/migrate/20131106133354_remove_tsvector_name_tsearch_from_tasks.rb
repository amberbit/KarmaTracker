class RemoveTsvectorNameTsearchFromTasks < ActiveRecord::Migration
  def up
    remove_column :tasks, :tsvector_name_tsearch
  end

  def down
    add_column :tasks, :tsvector_name_tsearch, :tsvector
  end
end
