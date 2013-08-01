class AddTsvectorDbStuff < ActiveRecord::Migration
  def up
    add_column :tasks, :tsvector_name_tsearch, :tsvector
    execute %q{CREATE INDEX tsvector_name_tsearch_idx ON tasks USING GIN(TO_TSVECTOR('english', name));}
  end

  def down
    remove_column :tasks, :tsvector_name_tsearch
    execute %q{DROP INDEX tsvector_name_tsearch_idx;}
  end
end
