require 'spec_helper'
require 'api/api_helper'

# Definitions: API Key = external service api key
#              Token = our API access token
#
# GET /user params: token or pass api key via header
#   - if api key valid
#     200 OK
#     { user: { id: 1, email: 'a@b.com', name: 'Hubert Lepicki', token: 'asdf2344' } }
#   - if invalid
#     401 Unauthorized
#     { message: 'Invalid API Token' }
#

describe 'User API' do

  before :each do
    @user = FactoryGirl.create :user
  end

  # GET /api/v1/user
  it 'should allow API access when providing valid token' do
    json = api_get 'user', {token: @user.api_key.token}

    response.status.should == 200
    json.has_key?('user').should be_true
    json['user']['email'].should == @user.email
  end

  # GET /api/v1/user
  it 'should deny API access when providing invalid token' do
    json = api_get 'user/', {token: 'invalid token'}

    response.status.should == 401
    json['message'].should == 'Invalid API Token'
  end

  # GET /api/v1/user
  it 'should allow sending API token in HTTP header' do
    get '/api/v1/user/', nil, {"HTTP_AUTHORIZATION" => "Token token=\"#{@user.api_key.token}\""}
    json = JSON.parse(response.body)

    response.status.should == 200
    json.has_key?('user').should be_true
  end

end
