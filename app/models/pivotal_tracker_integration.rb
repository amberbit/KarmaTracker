require 'net/http'
require 'net/https'
require 'open-uri'

class PivotalTrackerIntegration < Integration

  validate :credentials_correctness, on: :create
  validates_uniqueness_of :api_key

  def service_name
    "Pivotal Tracker"
  end

  private

  def credentials_correctness
    if api_key.present?
      validate_credentials_with_token
    elsif username.present? && password.present?
      validate_credentials_with_username_and_password
    else
      errors.add(:api_key, 'you need to provide login credentials')
    end
  rescue Exception
    errors.add(:api_key, 'could not get response from PT; Provided credentials might be invalid')
  end

  def validate_credentials_with_token
    https = Net::HTTP.new(authentication_uri.host, authentication_uri.port)
    https.use_ssl = true
    https.verify_mode = OpenSSL::SSL::VERIFY_NONE
    req = Net::HTTP::Get.new(authentication_uri.path)
    req["X-TrackerToken"] = api_key
    req["Content-Type"]="application/json"
    res = https.request(req)
    json = JSON.parse(res.body)
    token = json["api_token"]
    if token.present?
      self.api_key = token
      self.source_id = json["id"]
    else
      errors.add(:api_key, 'provided token is invalid')
    end
  rescue StandardError => e
    Rails.logger.warn "Exception when validating PT integration: #{e.class}: #{e.message}"

    errors.add(:api_key, 'provided token is invalid')
  end

  def validate_credentials_with_username_and_password
    https = Net::HTTP.new(authentication_uri.host, authentication_uri.port)
    https.use_ssl = true
    https.verify_mode = OpenSSL::SSL::VERIFY_NONE
    req = Net::HTTP::Get.new(authentication_uri.path)
    req["Content-Type"]="application/json"
    req.basic_auth username, password
    res = https.request(req)
    json = JSON.parse(res.body)
    token = json["api_token"]
    if token.present?
      self.api_key = token
      self.source_id = json["id"]
    else
      errors.add(:password, 'provided username/password combination is invalid')
    end
  rescue StandardError => e
    Rails.logger.warn "Exception when validating PT integration: #{e.class}: #{e.message}"

    errors.add(:password, 'provided username/password combination is invalid')
  end

  def authentication_uri
    URI('https://www.pivotaltracker.com/services/v5/me')
  end
end
