class Identity < ActiveRecord::Base
  attr_accessible :api_key, :user, :user_id, :source_id, :last_projects_refresh_at

  validates_uniqueness_of :api_key, :scope => :type
  validates_uniqueness_of :source_id, :scope => :type
  validates :type, presence: true
  validates :user, presence: true

  belongs_to :user
  has_many :participations, dependent: :destroy
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

  def to_snake_case
    service_name.gsub(' ', '').underscore
  end

  private

  def fetch_projects
    ProjectsFetcher.new.background.fetch_for_user(self.user)
  end

end
