class AddProjectsTsvector < ActiveRecord::Migration
  def up
    add_column :projects, :tsvector_name_tsearch, :tsvector
    execute %q{CREATE INDEX tsvector_projects_name_tsearch_idx ON projects USING GIN(TO_TSVECTOR('english', name));}
  end

  def down
    remove_column :projects, :tsvector_name_tsearch
    execute %q{DROP INDEX tsvector_projects_name_tsearch_idx;}
  end
end
