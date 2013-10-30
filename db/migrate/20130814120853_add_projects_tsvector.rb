class AddProjectsTsvector < ActiveRecord::Migration
  def up
    add_column :projects, :tsvector_name_tsearch, :tsvector
  end

  def down
    remove_column :projects, :tsvector_name_tsearch
  end
end
