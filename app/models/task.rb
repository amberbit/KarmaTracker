class Task < ActiveRecord::Base

  has_many :time_log_entries, dependent: :nullify

  def start user_id
    tl = time_log_entries.build user_id: user_id
    tl.start
  end

  def self.stop user_id
    TimeLogEntry.stop_all user_id
  end

end
