class Project < ActiveRecord::Base
  attr_accessible :name, :source_name, :source_identifier, :web_hook_token

  has_many :participations, dependent: :destroy
  has_many :identities, :through => :participations, :uniq  => true
  has_many :tasks, dependent: :destroy

  validates_uniqueness_of :source_identifier, :scope => :source_name

  after_create :generate_web_hook_token

  def users
    User.joins('INNER JOIN identities i ON i.user_id = users.id
                INNER JOIN participations p ON i.id = p.identity_id').
      where('p.identity_id IN(?)', identities.map(&:id)).uniq
  end


  def generate_web_hook_token
    if source_name == 'Pivotal Tracker'
      begin
        self.web_hook_token = SecureRandom.hex
      end while self.class.exists?(web_hook_token: web_hook_token)
    end
  end
end
