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
    json = api_post "session/",
                    session: {email: @user.email, password: 'secret123'}

    response.status.should == 200
    json.has_key?('user').should be_true
    json['user']['token'].should == @user.api_key.token
  end

  # POST /api/v1/session
  it 'should show error message when provided credentaials are invalid' do
    json = api_post 'session/',
                    session: {email: @user.email, password: 'wrong password'}

    response.status.should == 401
    json.has_key?('user').should be_false
    json['message'].should == 'Invalid email or password'
  end

  # POST /api/v1/session
  it 'should not raise application error when no credentials were provided' do
    json = api_post 'session/'

    response.status.should == 401
    json.has_key?('user').should be_false
    json['message'].should == 'Invalid email or password'
  end
end
