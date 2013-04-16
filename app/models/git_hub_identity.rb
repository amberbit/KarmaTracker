require 'net/http'
require 'net/https'
require 'uri'

class GitHubIdentity < Identity
  attr_accessible :username, :password
  attr_accessor :username, :password

  validate :credentials_correctness

  def service_name
    "GitHub"
  end

  private

  def credentials_correctness
    if username.present? && password.present?
      validate_credentials_with_username_and_password
    else
      errors.add(:api_key, 'you need to provide login credentials')
    end
  rescue
    errors.add(:api_key, 'could not get response from GH; Provided credentials might be invalid')
  end

  def validate_credentials_with_username_and_password
    https = Net::HTTP.new(authentication_uri.host, authentication_uri.port)
    https.use_ssl = true
    https.verify_mode = OpenSSL::SSL::VERIFY_NONE
    req = Net::HTTP::Post.new(authentication_uri.path)
    req.basic_auth username, password
    req.body = '{"scopes": ["user", "public_repo", "repo"]}'
    res = https.request(req)
    token = JSON.parse(res.body)["token"]
    if token.present?
      self.api_key = token
      self.source_identifier = username
    else
      raise Exception
    end
  rescue
    errors.add(:password, 'provided username/password combination is invalid')
  end

  def authentication_uri
    URI('https://api.github.com/authorizations')
  end

end
