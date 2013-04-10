class Task < ActiveRecord::Base

  has_many :time_log_entries, dependent: :nullify

  def start user_id
    TimeLogEntry.stop_all user_id

    tl = time_log_entries.build user_id: user_id, running: true, started_at: Time.zone.now
    tl.save!
  end

  def stop user_id
    if tl = time_log_entries.where({user_id: user_id, running: true}).first
      tl.stopped_at = Time.zone.now
      tl.running = false
      tl.save!
    end
  end

  def running? user_id
    time_log_entries.where({user_id: user_id, running: true}).present?
  end

end
