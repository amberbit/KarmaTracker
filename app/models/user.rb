class User < ActiveRecord::Base
  attr_accessible :api_key, :api_key_id, :email, :password_digest

  belongs_to :api_key, dependent: :destroy
  has_many :identities, dependent: :destroy

end
