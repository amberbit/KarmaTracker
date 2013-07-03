# == Schema Information
#
# Table name: users
#
#  id                 :integer          not null, primary key
#  email              :string(255)
#  password_digest    :string(255)
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#  confirmation_token :string(255)
#

class User < ActiveRecord::Base
  has_secure_password

  attr_accessible :email, :password, :confirmation_token

  has_one :api_key, dependent: :destroy
  has_many :time_log_entries, dependent: :destroy
  has_many :identities, dependent: :destroy

  validates :email, presence: true, uniqueness: true
  validates :password, presence: { on: :create },
                       length: { minimum: (AppConfig.users.password_min_chars || 6) },
                       if: :password_digest_changed?

  validates_format_of :email, :with => /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\Z/i

  before_create :generate_confirmation_token
  after_create :create_api_key

  def self.authenticate session
    session ||= {}
    User.find_by_email(session['email']).try(:authenticate, session['password'])
  end

  def running_task
    time_log_entries.where(running: true).first.try(:task)
  end

  def projects
    Project.joins('INNER JOIN participations p ON projects.id = p.project_id').
      where('p.identity_id IN(?)', identities.map(&:id)).uniq
  end

  def generate_confirmation_token
    begin
      self.confirmation_token = SecureRandom.hex
    end while User.find_by_confirmation_token(confirmation_token)
  end

  private

  def create_api_key
    ApiKey.create :user => self
  end

end
