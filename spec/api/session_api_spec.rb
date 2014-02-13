require 'spec_helper'
require 'api/api_helper'

# Definitions: API Key = external service api key
#              Token = our API access token

describe 'Session API (signing into the system)' do

  before :each do
    @user = FactoryGirl.create :user
  end

  # POST /api/v1/session
  it 'should return user with API Token when providing correct credentials' do
    @user.confirmation_token = nil
    @user.save
    json = api_post "session/",
                    session: {email: @user.email, password: 'secret123'}

    response.status.should == 200
    json['token'].should == @user.api_key.token
  end

  # POST /api/v1/session
  it 'should show error message when provided credentials are invalid' do
    json = api_post 'session/',
                    session: {email: @user.email, password: 'wrong password'}

    response.status.should == 401
    json.has_key?('user').should be_false
    json['message'].should == 'Invalid email or password'
  end

  # POST /api/v1/session
  it 'should show error message when provided user e-mail is not confirmed' do
    json = api_post 'session/',
                    session: {email: @user.email, password: 'secret123'}

    response.status.should == 401
    json.has_key?('user').should be_false
    json['message'].should == 'User email address is not confirmed, please check your inbox or spam folder.'
  end


  # POST /api/v1/session
  it 'should not raise application error when no credentials were provided' do
    json = api_post 'session/'

    response.status.should == 401
    json.has_key?('user').should be_false
    json['message'].should == 'Invalid email or password'
  end

  # GET /auth/:provider/callback
  it "should find existing user and redirect", omniauth_google: true do
    user = create :user, email: 'test@example.com', oauth_token: 'abc1234'
    expect {
      get "auth/google/callback", provider: 'google'
    }.not_to change{ User.count }
    response.status.should == 302
    response.should redirect_to("/#/oauth?email=#{user.email}&oauth_token=#{user.oauth_token}")
  end

  # GET /auth/:provider/callback
  it "should create new user and redirect", omniauth_google: true do
    get '/' #init request object
    request.env["omniauth.auth"] = OmniAuth.config.mock_auth[:google]
    expect {
      get "auth/google/callback", provider: 'google'
    }.to change{ User.count }.by(1)
    response.status.should == 302
    response.should redirect_to("/#/oauth?email=test@example.com&oauth_token=abc1234")
  end

  # GET /auth/:provider/callback
  it "should import GitHub identity/access token", omniauth_github: true do
    get '/' #init request object
    request.env["omniauth.auth"] = OmniAuth.config.mock_auth[:github]
    expect {
      get "auth/github/callback", provider: 'github'
    }.to change{ Integration.count }.by(1)
    user = User.find_by_email OmniAuth.config.mock_auth[:github].info.email
    user.integrations.count.should == 1
    user.integrations.last.type.should == 'GitHubIntegration'
  end

  # GET /auth/:provider/callback
  it "should redirect to failure action", omniauth_google: true do
    OmniAuth.config.mock_auth[:google] = :invalid_credentials
    get "auth/google/callback", provider: 'google'
    response.status.should == 302
    response.should redirect_to(root_path + 'auth/failure?message=invalid_credentials&strategy=google')
  end

  # GET /auth/failure
  it "should handle omniauth failures" do
    get 'auth/failure', message: 'invalid_credentials', strategy: 'google'
    response.status.should == 302
    response.should redirect_to(root_path)
  end

  # POST /api/v1/session/oauth_verify
  it 'should return user with API Token when providing correct email and token' do
    @user.oauth_token = 'lolz'
    @user.oauth_token_expires_at = 2.hours.from_now
    @user.save
    json = api_post "session/oauth_verify",
                    email: @user.email, token: @user.oauth_token

    response.status.should == 200
    json['token'].should == @user.api_key.token
  end


  # POST /api/v1/session/oauth_verify
  it "should return 404 - 'Email and OmniAuth token required' - error when no email" do
    json = api_post "session/oauth_verify", token: 'abc'

    response.status.should == 404
    json['message'].should == 'Email and OmniAuth token required'
  end

  # POST /api/v1/session/oauth_verify
  it "should return 404 - 'Email and OmniAuth token required' - error when no token" do
    json = api_post "session/oauth_verify", email: 'abc@amberbit.com'

    response.status.should == 404
    json['message'].should == 'Email and OmniAuth token required'
  end

  # POST /api/v1/session/oauth_verify
  it "should return 401 - 'Invalid OmniAuth token or user' - error when no user with that email" do
    @user.oauth_token = 'lolz'
    @user.save
    json = api_post "session/oauth_verify",
                    email: 'not_existing@user.com', token: @user.oauth_token

    response.status.should == 401
    json['message'].should == 'Invalid OmniAuth token or user'
  end

  # POST /api/v1/session/oauth_verify
  it "should return 401 - 'Invalid OmniAuth token or user' - error when user has no oauth token" do
    json = api_post "session/oauth_verify",
                    email: @user.email, token: 'notoken'

    response.status.should == 401
    json['message'].should == 'Invalid OmniAuth token or user'
  end

 # POST /api/v1/session/oauth_verify
  it "should return 401 - 'Invalid OmniAuth token or user' - error when token not my users" do
    @user.oauth_token = 'lolz'
    @user.oauth_token_expires_at = 2.hours.from_now
    @user.save
    json = api_post "session/oauth_verify",
                    email: @user.email, token: 'not_my_token'

    response.status.should == 401
    json['message'].should == 'Invalid OmniAuth token or user'
  end

  # POST /api/v1/session/oauth_verify
  it "should return 400 - 'OmniAuth token expired' - error when token expired" do
    @user.oauth_token = 'lolz'
    @user.oauth_token_expires_at = 2.hours.ago
    @user.save
    json = api_post "session/oauth_verify",
                    email: @user.email, token: @user.oauth_token

    response.status.should == 400
    json['message'].should == 'OmniAuth token expired'
  end
end
