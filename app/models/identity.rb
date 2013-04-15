class Identity < ActiveRecord::Base
  attr_accessible :name, :api_key, :user, :user_id, :source_id, :last_projects_refresh_at

  validates_uniqueness_of :api_key, :scope => :type
  validates_uniqueness_of :source_id, :scope => :type
  validates :type, presence: true

  belongs_to :user
  has_many :participations
  has_many :projects, :through => :participations

  after_create :fetch_projects

  def service_name
    # overwrite in subclass
  end

  def self.by_service(service)
    service = service.camelize
    sevice = service.concat('Identity') unless service =~ /Identity\z/
    where(:type => service)
  end

  private

  def fetch_projects
    ProjectsFetcher.new.background.fetch_for_identity(self)
  end

end
