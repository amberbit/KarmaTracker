class User < ActiveRecord::Base
  has_secure_password

  attr_accessible :email, :password

  has_one :api_key, :dependent => :destroy
  has_many :identities

  validates :email, :presence  => true

  after_create :create_api_key

  def self.authenticate email, password
    User.find_by_email(email).try(:authenticate, password)
  end

  def projects
    Project.joins('INNER JOIN participations p ON projects.id = p.project_id').
      where('p.identity_id IN(?)', identities.map(&:id)).uniq
  end

  private

  def create_api_key
    ApiKey.create :user => self
  end

end
