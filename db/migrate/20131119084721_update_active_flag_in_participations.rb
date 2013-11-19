class UpdateActiveFlagInParticipations < ActiveRecord::Migration
  def up
    execute "UPDATE participations SET active = TRUE WHERE active IS NULL"
  end

  def down
  end
end
