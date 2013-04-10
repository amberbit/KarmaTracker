class Project < ActiveRecord::Base
  attr_accessible :name, :source_name, :source_identifier

  has_many :participations
  has_many :users, :through => :participations, uniq: true

  validates_uniqueness_of :source_identifier, :scope => :source_name
end
