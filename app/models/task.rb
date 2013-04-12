class Task < ActiveRecord::Base

  attr_accessible :project, :project_id

  has_many :time_log_entries, dependent: :nullify

  belongs_to :project

  validates :project_id, presence: true

  def running? user_id
    time_log_entries.where({user_id: user_id, running: true}).present?
  end

end
