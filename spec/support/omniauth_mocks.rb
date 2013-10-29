class OmniAuthMocks
  attr_accessor :omniauth_hash

  def initialize
    @omniauth_hash = { 'uid' => '12345',
                       'info' => {
      'email' => 'test@example.com',
    },
    'credentials' => { 'token' => 'abc1234',
                       'expires_at' => 2.hours.from_now.to_i }
    }
  end

  def mock_google
    @omniauth_hash['provider'] = 'google'
    OmniAuth.config.add_mock(:google, omniauth_hash)
  end

  def mock_github
    @omniauth_hash['provider'] = 'github'
    OmniAuth.config.add_mock(:github, omniauth_hash)
  end

end
