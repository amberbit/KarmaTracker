class TimeLogEntry < ActiveRecord::Base

  attr_accessible :task, :task_id, :user, :user_id, :running, :started_at, :stopped_at, :seconds

  belongs_to :task
  belongs_to :user

  validates :seconds, presence: true, numericality: { only_integer: true, greater_than_or_equal_to: 0 }
  validates :started_at, presence: true
  validates :user, presence: true
  validate :time_order, if: "stopped_at.present?"
  validate :time_overlapping

  before_save :calculate_logged_seconds, if: "stopped_at.present?"

  scope :from_timestamp, lambda { |timestamp|
    where("(?::timestamp with time zone) BETWEEN started_at AND stopped_at", timestamp)
  }

  scope :within_timerange, lambda { |start,stop|
    where("(?::timestamp with time zone, ?::timestamp with time zone) OVERLAPS (started_at, stopped_at)", start, stop)
  }

  def start
    TimeLogEntry.stop_all user_id
    self.started_at = Time.zone.now
    self.running = true
    self.save!
  end

  def stop
    self.stopped_at = Time.zone.now
    self.running = false
    self.save!
  end

  def self.stop_all user_id
    TimeLogEntry.where({user_id: user_id, running: true}).each do |tl| tl.stop; end
  end

  private

  def calculate_logged_seconds
    if started_at_changed? || stopped_at_changed?
      self.seconds = (stopped_at - started_at).to_i
    end
  end

  def time_order
    if started_at > stopped_at
      errors.add :stopped_at, 'must be after start time'
    end
  end

  def time_overlapping
    scope = TimeLogEntry.where(user_id: user_id)
    scope = scope.where("id <> ?", id) if self.persisted?

    if started_at.present? && scope.from_timestamp(started_at).present?
      errors.add :started_at, 'should not overlap other time log entries'
    end

    if started_at.present? && stopped_at.present? && scope.within_timerange(started_at, stopped_at).present?
      errors.add :stopped_at, 'should not overlap other time log entries'
    end
  end

end
