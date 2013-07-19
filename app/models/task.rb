# == Schema Information
#
# Table name: tasks
#
#  id                :integer          not null, primary key
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  project_id        :integer          not null
#  name              :text             not null
#  source_name       :string(255)      not null
#  source_identifier :string(255)      not null
#  current_state     :string(255)      not null
#  story_type        :string(255)      not null
#  current_task      :boolean          default(FALSE)
#

class Task < ActiveRecord::Base
  include PgSearch

  attr_accessible :project, :project_id, :source_name, :source_identifier,
                  :current_state, :story_type, :name, :current_task

  has_many :time_log_entries, dependent: :nullify

  belongs_to :project

  validates_presence_of :project_id, :source_name, :source_identifier,
                        :current_state, :story_type
  validates_uniqueness_of :source_identifier, :scope => :source_name

  after_save :update_tsvector

  pg_search_scope :search_by_name, :against => :name,
    using: {
      tsearch: {
        dictionary: 'english',
        tsvector_column: 'tsvector_name_tsearch',
        prefix: true
      }
    }

  def self.current
    where(current_task: true)
  end

  def self.recent(user = nil)
    query = select("tasks.*, MAX(time_log_entries.started_at) max_started_at").
            joins("inner join time_log_entries on time_log_entries.task_id = tasks.id").
            group("tasks.id").
            order("max_started_at desc")

    query = query.where("time_log_entries.user_id = ?", user.id) if user

    query.limit(5)
  end

  def running? user_id
    time_log_entries.where({user_id: user_id, running: true}).present?
  end

  private 
    def update_tsvector
      query = "UPDATE tasks SET tsvector_name_tsearch = TO_TSVECTOR('english', '#{self.name.gsub("'", "''")}') WHERE id = #{self.id};"
      ActiveRecord::Base.connection.execute query
    end
end
