class Participation < ActiveRecord::Base
  belongs_to :integration
  belongs_to :project
  attr_accessible :active
end
