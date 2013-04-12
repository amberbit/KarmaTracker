require 'spec_helper'
require 'api/api_helper'

# Definitions: API Key = external service api key
#              Token = our API access token

describe 'Session API (signing into the system)' do

  before :each do
    @user = FactoryGirl.create :user
  end

  # POST /api/v1/sessions
  it 'should return user with API Token when providing correct credentials' do
    json = api_post "sessions/",
                    session: {email: @user.email, password: 'secret'}

    response.status.should == 200
    json.has_key?('user').should be_true
    json['user']['token'].should == @user.api_key.token
  end

  # POST /api/v1/sessions
  it 'should show error message when provided credentaials are invalid' do
    json = api_post 'sessions/', 
                    session: {email: @user.email, password: 'wrong password'}

    response.status.should == 401
    json.has_key?('user').should be_false
    json['message'].should == 'Invalid email or password'
  end
end

