class Task < ActiveRecord::Base

  has_many :time_log_entries, dependent: :nullify

  def running? user_id
    time_log_entries.where({user_id: user_id, running: true}).present?
  end

end
