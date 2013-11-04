class RemoveTsvectorNameTsearchFromProjects < ActiveRecord::Migration
  def up
    remove_column :projects, :tsvector_name_tsearch
  end

  def down
    add_column :projects, :tsvector_name_tsearch, :tsvector
  end
end
