class User < ActiveRecord::Base
  has_secure_password

  attr_accessible :email, :password

  has_one :api_key, dependent: :destroy
  has_many :time_log_entries, dependent: :destroy

  validates :email, presence: true, uniqueness: true

  after_create :create_api_key

  def self.authenticate email, password
    User.find_by_email(email).try(:authenticate, password)
  end

  def running_task
    time_log_entries.where(running: true).first.try(:task)
  end

  private

  def create_api_key
    ApiKey.create user: self
  end

end
