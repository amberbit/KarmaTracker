class Project < ActiveRecord::Base
  attr_accessible :name, :source_name, :source_identifier, :hook

  has_many :participations, dependent: :destroy
  has_many :identities, :through => :participations, :uniq  => true
  has_many :tasks, dependent: :destroy

  validates_uniqueness_of :source_identifier, :scope => :source_name

  before_destroy :destroy_hook

  def users
    User.joins('INNER JOIN identities i ON i.user_id = users.id
                INNER JOIN participations p ON i.id = p.identity_id').
      where('p.identity_id IN(?)', identities.map(&:id)).uniq
  end

  def destroy_hook
    if source_name == 'GitHub' && hook
      repo_owner = name.split('/').first
      repo_owner_identity = Identity.by_service('GitHub').where(source_id: repo_owner).first
      GitHubWebHooksManager.new({project: self}).destroy_hook(repo_owner_identity) if repo_owner_identity
    end
  end

end
