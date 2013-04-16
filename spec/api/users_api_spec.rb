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

  # PUT /api/v1/user
  it 'should change user\'s email and password' do
    old_user = @user.dup
    json = api_put 'user', {token: @user.api_key.token, user: {email: 'new@sample.com', password: 'new password'}}

    response.status.should == 200
    json.has_key?('user').should be_true
    json['user']['email'].should == 'new@sample.com'

    api_post "session/", session: {email: old_user.email, password: 'secret123'}
    response.status.should == 401

    api_post "session/", session: {email: 'new@sample.com', password: 'new password'}
    response.status.should == 200
  end

  # DELETE /api/v1/user
  it 'should completely remove user and all his identities/keys' do
    FactoryGirl.create :identity
    User.count.should == 1
    Identity.count.should == 1
    ApiKey.count.should == 1

    json = api_delete 'user', {token: @user.api_key.token}

    response.status.should == 200
    User.count.should == 0
    Identity.count.should == 0
    ApiKey.count.should == 0
  end

  # DELETE /api/v1/user
  it 'should deny removing user when allow_destroy_user is set to false' do
    AppConfig.allow_destroy_user = false

    User.count.should == 1
    json = api_delete 'user', {token: @user.api_key.token}

    response.status.should == 403
    json['message'].should == 'Forbidden'
    User.count.should == 1

    AppConfig.allow_destroy_user = true
  end

end
