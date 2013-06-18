class AddConfirmationTokenToUsers < ActiveRecord::Migration
  def up
    change_table :users do |t|
      t.string :confirmation_token
    end

    add_index :users, :confirmation_token, unique: true
  end

  def down
    change_table :users do |t|
      t.remove :confirmation_token
    end
  end
end
