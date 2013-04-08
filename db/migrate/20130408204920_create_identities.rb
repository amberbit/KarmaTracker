class CreateIdentities < ActiveRecord::Migration
  def change
    create_table :identities do |t|
      t.string :type
      t.string :name
      t.string :api_key

      t.references :user

      t.timestamps
    end
  end
end
