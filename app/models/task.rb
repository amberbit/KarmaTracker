class Task < ActiveRecord::Base
  include Flex::ModelIndexer
  flex.sync self

  def flex_source
    { id: id,
      project_id: project_id,
      source_name: source_name,
      source_identifier: source_identifier,
      current_state: current_state,
      story_type: story_type,
      current_task: current_task,
      name: name
    }
  end

  module Flex
    include ::Flex::Scopes
    flex.context = Task
    scope :search_by_id_and_name do |names, ids|
      filters(prefix: { name: names }).filters(ids: { values: ids } )
    end
  end

  attr_accessible :project, :project_id, :source_name, :source_identifier,
                  :current_state, :story_type, :name, :current_task

  has_many :time_log_entries, dependent: :nullify

  belongs_to :project
  acts_as_list scope: :project

  validates_presence_of :project_id, :source_name, :source_identifier,
                        :current_state, :story_type
  validates_uniqueness_of :source_identifier, :scope => :source_name

  def self.current
    where(current_task: true)
  end

  def self.recent(user = nil)
    query = select("tasks.*, MAX(time_log_entries.started_at) max_started_at").
            joins("inner join time_log_entries on time_log_entries.task_id = tasks.id").
            group("tasks.id").
            reorder("max_started_at desc")

    query = query.where("time_log_entries.user_id = ?", user.id) if user

    query.limit(5)
  end

  def self.running? task_id, user_id
    task = Task.find_by_id(task_id)
    task.present? ? task.time_log_entries.where({user_id: user_id, running: true}).present? : nil
  end

end
