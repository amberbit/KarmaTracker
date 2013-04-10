class CreateTimeLogEntries < ActiveRecord::Migration
  def change
    create_table :time_log_entries do |t|
      t.references :task
      t.references :user, null: false
      t.boolean :running, default: false
      t.timestamp :started_at, null: false
      t.timestamp :stopped_at
      t.integer :seconds, null: false, default: 0

      t.timestamps
    end
  end
end
