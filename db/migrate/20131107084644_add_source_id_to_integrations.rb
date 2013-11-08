class AddSourceIdToIntegrations < ActiveRecord::Migration
  def change
    Integration.reset_column_information
    #TODO write down migration
    add_column(:integrations, :source_id, :string, null: false) unless Integration.column_names.include?("source_id")
  end
end
