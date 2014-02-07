class TimeLogEntry < ActiveRecord::Base
  include Flex::ModelIndexer
  flex.sync self

  def flex_source
    { id: id,
      task_id: task.id,
      user_id: user_id,
      running: running,
      started_at: started_at,
      stopped_at: stopped_at,
      seconds: seconds,
      project_id: task.project.id
    }
  end

  module Flex
    include ::Flex::Scopes
    flex.context = TimeLogEntry

    scope :by_user, ->(users_id) { term(user_id: users_id) }
    scope :before_started_at, ->(timestamp) { filters(range: {started_at: {lte: timestamp} } ) }
    scope :after_started_at, ->(timestamp) { filters(range: {started_at: {gte: timestamp} } ) }
    scope :before_stopped_at, ->(timestamp) { filters(range: {stopped_at: {lte: timestamp} } ) }
    scope :after_stopped_at, ->(timestamp) { filters(range: {stopped_at: {gte: timestamp} } ) }

    scope :by_project, ->(projects_id) { term(project_id: projects_id) }
    scope :except_id, ->(ids) { filters(:not => { ids: {values: ids}} ) }
    scope :running, -> { term(running: true) }
  end

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
    scope = Flex.by_user(user_id)
    scope = scope.except_id([id]) if self.persisted?

    if started_at.present? && (start_overlapped = scope.before_started_at(started_at).after_stopped_at(started_at)).any?
      id = start_overlapped.first['_source']['id']
      errors.add :started_at, 'should not overlap other time log entries', { id: id }
      errors.add :started_at, "id:#{id}"
    end

    if stopped_at.present? && (stop_overlapped = scope.before_started_at(stopped_at).after_stopped_at(stopped_at)).any?
      id = stop_overlapped.first['_source']['id']
      errors.add :stopped_at, 'should not overlap other time log entries', { id: id }
      errors.add :stopped_at, "id:#{id}"
    end

    if started_at.present? && stopped_at.present? && (overlapped = scope.after_started_at(started_at).before_stopped_at(stopped_at)).any?
      id = overlapped.first['_source']['id']
      errors.add :stopped_at, 'whole entry should not contain other time log entries', { id: overlapped.first['id'] }
      errors.add :stopped_at, "id:#{id}"
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
