class MoveUserApiKeyIdForeignKey < ActiveRecord::Migration
  def up
    remove_column :users, :api_key_id
    change_table :api_keys do |t|
      t.references :user
    end
  end

  def down
    remove_column :api_keys, :user_id
    change_table :users do |t|
      t.references :api_key
    end
  end
end
