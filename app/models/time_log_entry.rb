# == Schema Information
#
# Table name: time_log_entries
#
#  id         :integer          not null, primary key
#  task_id    :integer
#  user_id    :integer          not null
#  running    :boolean          default(FALSE)
#  started_at :datetime         not null
#  stopped_at :datetime
#  seconds    :integer          default(0), not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class TimeLogEntry < ActiveRecord::Base

  attr_accessible :task, :task_id, :user, :user_id, :running, :started_at, :stopped_at, :seconds

  belongs_to :task
  belongs_to :user

  validates :seconds, presence: true, numericality: { only_integer: true, greater_than_or_equal_to: 0 }
  validates :started_at, presence: true
  validates :user, presence: true
  validates :task, presence: true, on: :create
  validate :time_order, if: "stopped_at.present?"
  validate :time_overlapping
  validate :time_in_future

  before_save :calculate_logged_time

  scope :from_timestamp, lambda { |timestamp|
    where("timestamp :stamp BETWEEN started_at AND stopped_at", stamp: timestamp)
  }

  scope :within_timerange, lambda { |start,stop|
    where("(started_at, stopped_at) OVERLAPS (timestamp :start, timestamp :stop)", start: start, stop: stop)
  }

  scope :after_timestamp, lambda { |str_timestamp|
    where("stopped_at > ?", Time.zone.parse(str_timestamp))
  }

  scope :before_timestamp, lambda { |str_timestamp|
    where("started_at <= ?", Time.zone.parse(str_timestamp))
  }

  scope :from_project, lambda { |project_id|
    joins(:task).where('tasks.project_id = ?', project_id)
  }

  def start
    self.running = true
    self.started_at = Time.zone.now
    self
  end

  def self.stop_all user_id
    TimeLogEntry.where({user_id: user_id, running: true}).each do |tl|
      tl.stopped_at = Time.zone.now - 1
      tl.running = false
      tl.save!
    end
  end

  private

  def calculate_logged_time
    if stopped_at.present?
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
      errors.add :started_at, 'should not overlap other time log entries', { id: scope.from_timestamp(started_at).first.id }
      errors.add :started_at, "id:#{ scope.from_timestamp(started_at).first.id }"
    end

    if stopped_at.present? && scope.from_timestamp(stopped_at).present?
      errors.add :stopped_at, 'should not overlap other time log entries', { id: scope.from_timestamp(stopped_at).first.id }
      errors.add :stopped_at, "id:#{ scope.from_timestamp(stopped_at).first.id }"
    end

    if started_at.present? && stopped_at.present? && scope.within_timerange(started_at, stopped_at).present?
      errors.add :stopped_at, 'should not overlap other time log entries', { id: scope.within_timerange(started_at, stopped_at).first.id }
      errors.add :stopped_at, "id:#{ scope.within_timerange(started_at, stopped_at).first.id }"
    end
  end

  def time_in_future
    if started_at.present? && started_at > Time.zone.now
      errors.add :started_at, 'should not be in the future'
    end

    if stopped_at.present? && stopped_at > Time.zone.now
      errors.add :stopped_at, 'should not be in the future'
    end
  end

end
