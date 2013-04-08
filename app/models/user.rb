class User < ActiveRecord::Base
  attr_accessible :api_key_id, :email, :password_digest

  has_many :api_keys, dependent: :destroy
  has_many :identities, dependent: :destroy

end
