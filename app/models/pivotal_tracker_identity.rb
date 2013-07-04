# == Schema Information
#
# Table name: identities
#
#  id                       :integer          not null, primary key
#  type                     :string(255)
#  name                     :string(255)
#  api_key                  :string(255)
#  user_id                  :integer
#  created_at               :datetime         not null
#  updated_at               :datetime         not null
#  source_id                :string(255)      not null
#  last_projects_refresh_at :datetime
#

require 'net/http'
require 'net/https'
require 'open-uri'

class PivotalTrackerIdentity < Identity
  attr_accessible :email, :password
  attr_accessor :email, :password

  validate :credentials_correctness, on: :create
  validates_uniqueness_of :api_key

  def service_name
    "Pivotal Tracker"
  end

  private

  def credentials_correctness
    if api_key.present?
      validate_credentials_with_token
    elsif email.present? && password.present?
      validate_credentials_with_email_and_password
    else
      errors.add(:api_key, 'you need to provide login credentials')
    end
  rescue Exception
    errors.add(:api_key, 'could not get response from PT; Provided credentials might be invalid')
  end

  def validate_credentials_with_token
    doc = Nokogiri::XML(open(authentication_uri, 'X-TrackerToken' => api_key))
    key = doc.xpath('//token/guid').first
    if key.present?
      self.api_key = key.content
      self.source_id = doc.xpath('//id').first.content
    else
      errors.add(:api_key, 'provided API token is invalid')
    end
  end

  def validate_credentials_with_email_and_password
    doc = Nokogiri::XML(open(authentication_uri, :http_basic_authentication => [email, password]))
    key = doc.xpath('//token/guid').first
    if key.present?
      self.api_key = key.content
      self.source_id = doc.xpath('//id').first.content
    else
      errors.add(:password, 'provided email/password combination is invalid')
    end
  end

  def authentication_uri
    URI('https://www.pivotaltracker.com/services/v4/me')
  end
end
