class Identity < ActiveRecord::Base
  attr_accessible :name, :api_key

  belongs_to :user
end
