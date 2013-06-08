class RemoveAdminFlagFromUsers < ActiveRecord::Migration
  def up
    change_table :api_keys do |t|
      t.remove :admin
    end
  end

  def down
    change_table :api_keys do |t|
      t.boolean :admin, default: false
    end
  end
end
