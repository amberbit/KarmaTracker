class User < ActiveRecord::Base
  has_secure_password

  attr_accessible :email, :password

  has_one :api_key, dependent: :destroy
  has_many :time_log_entries, dependent: :destroy
  has_many :identities

  validates :email, presence: true, uniqueness: true

  after_create :create_api_key

  def self.authenticate session
    session ||= {}
    User.find_by_email(session['email']).try(:authenticate, session['password'])
  end

  def running_task
    time_log_entries.where(running: true).first.try(:task)
  end

  private

  def create_api_key
    ApiKey.create user: self
  end

end
