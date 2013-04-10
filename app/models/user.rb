class User < ActiveRecord::Base
  has_secure_password

  attr_accessible :email, :password

  has_one :api_key, dependent: :destroy
  has_many :identities
  has_many :participations
  has_many :projects, :through => :participations, uniq: true

  validates :email, presence: true, uniqueness: true

  after_create :create_api_key

  def self.authenticate email, password
    User.find_by_email(email).try(:authenticate, password)
  end

  private

  def create_api_key
    ApiKey.create user: self
  end

end
