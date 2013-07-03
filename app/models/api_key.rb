# == Schema Information
#
# Table name: api_keys
#
#  id         :integer          not null, primary key
#  token      :string(255)      not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  user_id    :integer
#

class ApiKey < ActiveRecord::Base

  attr_accessible :user, :token

  belongs_to :user

  before_create :generate_token

  private

  def generate_token
    begin
      self.token = SecureRandom.hex
    end while self.class.exists?(token: token)
  end

end
