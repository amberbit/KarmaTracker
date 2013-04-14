class CreateUniqueIndexOnSourceNameAndSourceIdentifierForProjects < ActiveRecord::Migration
  def change
    add_index :projects, [:source_name, :source_identifier], :unique => true
  end
end
