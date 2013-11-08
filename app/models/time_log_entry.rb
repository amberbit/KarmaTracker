class TimeLogEntry < ActiveRecord::Base
  include Flex::ModelIndexer
  flex.sync self

  def flex_source
    { id: id,
      started_at: started_at,
      stopped_at: stopped_at,
      user_id: user_id
    }
  end

  module Flex
    include ::Flex::Scopes
    flex.context = TimeLogEntry

    #scope :by_id, ->(ids) { filters(ids: { values: ids } ) }
    scope :by_user, ->(users_id) { term(user_id: users_id) }
    scope :after_timestamp, ->(started_at_timestamp) { range(started_at: { from: started_at_timestamp }) }
    scope :before_timestamp, ->(stopped_at_timestamp) { range(stopped_at: { to: stopped_at_timestamp }) }
    scope :search_time_log_entries do |user_id, started_at, stopped_at|
      result = by_user(user_id)
      result = result.after_timestamp(started_at) if started_at.present?
      result = result.before_timestamp(stopped_at) if stopped_at.present?
      result
    end
  end

  #scope :after_timestamp, lambda { |str_timestamp|
    #where("stopped_at > ?", Time.zone.parse(str_timestamp))
  #}

  #scope :before_timestamp, lambda { |str_timestamp|
    #where("started_at <= ?", Time.zone.parse(str_timestamp))
  #}

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


  scope :from_project, lambda { |project_id|
    joins(:task).where('tasks.project_id = ?', project_id)
  }

  scope :running, where(running: true)

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
