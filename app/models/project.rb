class Project < ActiveRecord::Base
  include PgSearch

  attr_accessible :name, :source_name, :source_identifier, :web_hook, :web_hook_token

  has_many :participations, dependent: :destroy
  has_many :identities, :through => :participations, :uniq  => true
  has_many :tasks, dependent: :destroy

  validates_uniqueness_of :source_identifier, :scope => :source_name

  before_create :generate_web_hook_token
  before_destroy :destroy_web_hook

  after_save :update_tsvector
  pg_search_scope :search_by_name, :against => :name,
    using: {
      tsearch: {
        dictionary: 'english',
        tsvector_column: 'tsvector_name_tsearch',
        prefix: true
      }
    }

    scope :also_working,  ->(ids) { joins(:tasks).
                              joins('LEFT OUTER JOIN time_log_entries ON tasks.id = time_log_entries.task_id').
                              joins('INNER JOIN users ON users.id = time_log_entries.user_id').
                              where('time_log_entries.running = ? AND projects.id IN (?)', true, ids).
                              includes( tasks: [time_log_entries: :user]).uniq }
  def users
    User.joins('INNER JOIN identities i ON i.user_id = users.id
                INNER JOIN participations p ON i.id = p.identity_id').
      where('p.identity_id IN(?)', identities.map(&:id)).uniq
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
      repo_owner_identity = Identity.by_service('GitHub').where(source_id: repo_owner).first
      GitHubWebHooksManager.new({project: self}).destroy_hook(repo_owner_identity) if repo_owner_identity
    end
  end

  def generate_web_hook_token
    begin
      self.web_hook_token = SecureRandom.hex
    end while self.class.exists?(web_hook_token: web_hook_token)
  end

  private 
    def update_tsvector
      query = "UPDATE projects SET tsvector_name_tsearch = TO_TSVECTOR('english', '#{self.name.gsub("'", "''")}') WHERE id = #{self.id};"
      ActiveRecord::Base.connection.execute query
    end
end
