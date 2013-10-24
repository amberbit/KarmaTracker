class User < ActiveRecord::Base
  has_secure_password

  attr_accessible :email, :password, :confirmation_token, :refreshing, :gravatar_url, :oauth_token

  has_one :api_key, dependent: :destroy
  has_many :time_log_entries, dependent: :destroy
  has_many :integrations, dependent: :destroy

  validates :email, presence: true, uniqueness: true
  validates :password, presence: { on: :create },
                       length: { minimum: (AppConfig.users.password_min_chars || 6) },
                       if: :password_digest_changed?

  validates_format_of :email, :with => /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\Z/i

  before_create :generate_tokens
  after_create :create_api_key
  after_create :gravatar_url

  def self.authenticate session
    session ||= {}
    User.find_by_email(session['email']).try(:authenticate, session['password'])
  end

  def running_task
    time_log_entries.where(running: true).first.try(:task)
  end

  def projects
    Project.joins('INNER JOIN participations p ON projects.id = p.project_id').
      where('p.identity_id IN(?)', integrations.map(&:id)).uniq
  end

  def generate_token(column)
    begin
      self[column] = SecureRandom.hex
    end while User.exists?(column => self[column])
  end

  def gravatar_url
    @gravatar_url ||= "http://www.gravatar.com/avatar/" + Digest::MD5.hexdigest(self.email)
  end

  def send_password_reset(host)
    @host = host
    generate_token(:password_reset_token)
    update_password_reset_sent_at
    send_email
  end

  private

  def create_api_key
    ApiKey.create :user => self
  end

  def generate_tokens
    generate_token :confirmation_token
    generate_token :auth_token
  end

  def update_password_reset_sent_at
    self.password_reset_sent_at = Time.zone.now
    save!
  end

  def send_email
    UserMailer.password_reset(self, @host).deliver
  end
end
