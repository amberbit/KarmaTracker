class Project < ActiveRecord::Base

  include Flex::ModelIndexer
  flex.sync self

  def flex_source
    { id: id,
      name: name,
      source_name: source_name,
      source_identifier: source_identifier,
      task_count: tasks.count }
  end

  module Flex
    include ::Flex::Scopes
    flex.context = Project
    scope :search_by_id_and_name do |names, ids|
      filters(prefix: { name: names }).filters(ids: { values: ids } )
    end
  end

  attr_accessible :name, :source_name, :source_identifier, :web_hook, :web_hook_token, :web_hook_time, :web_hook_exists

  has_many :participations, dependent: :destroy
  has_many :integrations, :through => :participations, :uniq  => true
  has_many :tasks, :order => "position ASC", dependent: :destroy

  validates_uniqueness_of :source_identifier, :scope => :source_name

  before_create :generate_web_hook_token
  before_destroy :destroy_web_hook

  scope :also_working,  ->(ids) { joins(:tasks).
                            joins('LEFT OUTER JOIN time_log_entries ON tasks.id = time_log_entries.task_id').
                            joins('INNER JOIN users ON users.id = time_log_entries.user_id').
                            where('time_log_entries.running = ? AND projects.id IN (?)', true, ids).
                            includes( tasks: [time_log_entries: :user]).uniq }

  scope :active,  ->(user) { joins('INNER JOIN participations p ON projects.id = p.project_id').
      where('p.integration_id IN(?) AND active', user.integrations.map(&:id)).uniq }

  def users
    User.joins('INNER JOIN integrations i ON i.user_id = users.id
                INNER JOIN participations p ON i.id = p.integration_id').
      where('p.integration_id IN(?)', integrations.map(&:id)).uniq
  end

  def task_count
    tasks.count
  end

  def active_for_user?(user = nil)
    if user
      p = participations.where('integration_id IN (?)',user.integrations.map(&:id)).first
      if p
        p.active
      else
        false
      end
    else
      false
    end
  end

  def toggle_active_for_user(user = nil)
    if user
      p = participations.where('integration_id IN (?)',user.integrations.map(&:id)).first
      p.active = !p.active
      p.save
    end
  end

  def self.recent(user = nil)
    query = select("projects.*, MAX(time_log_entries.started_at) max_started_at").
            joins("inner join tasks on projects.id = tasks.project_id").
            joins("inner join time_log_entries on time_log_entries.task_id = tasks.id").
            group("projects.id").
            order("max_started_at desc")

    query = query.where("time_log_entries.user_id = ?", user.id) if user

    query.limit(5)
  end


  def destroy_web_hook
    if source_name == 'GitHub' && web_hook
      repo_owner = name.split('/').first
      repo_owner_integration = Integration.by_service('GitHub').where(source_id: repo_owner).first
      GitHubWebHooksManager.new({project: self}).destroy_hook(repo_owner_integration) if repo_owner_integration
    end
  end

  def generate_web_hook_token
    begin
      self.web_hook_token = SecureRandom.hex.to_s
    end while self.class.exists?(web_hook_token: web_hook_token)
  end

end
