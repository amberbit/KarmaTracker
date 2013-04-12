class CreateProjects < ActiveRecord::Migration
  def up
    create_table :projects do |t|
      t.string :name,               :null => false

      t.string :source_name,        :null => false
      t.string :source_identifier,  :null => false

      t.timestamps
    end

    create_table :participations do |t|
      t.references :user,           :null => false
      t.references :project,        :null => false

      t.timestamps
    end
  end
end
