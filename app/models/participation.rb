class Participation < ActiveRecord::Base
  belongs_to :integration
  belongs_to :project
end
