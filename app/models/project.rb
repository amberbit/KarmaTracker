class Project < ActiveRecord::Base
  attr_accessible :name, :source_name, :source_identifier

  has_many :participations
  has_many :identities, :through => :participations, :uniq  => true
  has_many :tasks, dependent: :destroy

  validates_uniqueness_of :source_identifier, :scope => :source_name

  def users
    User.joins('INNER JOIN identities i ON i.user_id = users.id
                INNER JOIN participations p ON i.id = p.identity_id').
      where('p.identity_id IN(?)', identities.map(&:id)).uniq
  end
end
