class AddSourceIdToIntegrations < ActiveRecord::Migration
  def up
    Integration.reset_column_information
    add_column(:integrations, :source_id, :string, null: false) unless Integration.column_names.include?("source_id")
  end

  def down
    Integration.reset_column_information
    remove_column(:integrations, :source_id) if Integration.column_names.include?("source_id")
  end
end
