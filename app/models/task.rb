class Task < ActiveRecord::Base

  attr_accessible :project, :project_id, :source_name, :source_identifier,
                  :current_state, :story_type, :name, :current_task

  has_many :time_log_entries, dependent: :nullify

  belongs_to :project

  validates_presence_of :project_id, :source_name, :source_identifier,
                        :current_state, :story_type
  validates_uniqueness_of :source_identifier, :scope => :source_name

  def self.current
    where(current_task: true)
  end

  def running? user_id
    time_log_entries.where({user_id: user_id, running: true}).present?
  end

end
