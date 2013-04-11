require 'spec_helper'
require 'api/api_helper'

# Definitions: API Key = external service api key
#              Token = our API access token
#
# POST /sessions
# params: session[email]: a@b.com, session[password]: somepass}
#  - if logged in:
#    200 OK
#    { id: 1, email: 'a@b.com', name: 'Hubert Lepicki', token: 'asdf2344' }
#  - if credentials invalid
#    401 Unauthorized
#    { message: 'Invalid email or password' }
#
# GET /me -- delete please
#
# GET /user params: token or pass api key via header
#   - if api key valid
#     200 OK
#     { id: 1, email: 'a@b.com', name: 'Hubert Lepicki', token: 'asdf2344' }
#   - if invalid
#     401 Unauthorized
#     { message: 'Invalid API Key' }
#

describe 'User API' do

  before :each do
    @user = FactoryGirl.create :user
  end

  it 'should return user\'s token when providing correct credentials' do
    api_get "users/authenticate", {email: @user.email, password: 'secret'}

    @response.has_key?('token').should be_true
    @response['token'].should == @user.token.access_token
  end

  it 'should not return token when providing wrong credentaials' do
    api_get "users/authenticate", {email: @user.email, password: 'wrong password'}

    @response.has_key?('token').should be_false
    @response['status'].should == 401
  end

  it 'should allow API access when providing valid token' do
    api_get "users/me", {token: @user.token.access_token}

    @response.has_key?("user").should be_true
    @response['user']['email'].should == @user.email
  end

  it 'should deny API access when providing invalid token' do
    api_get "users/me", {token: 'invalid token'}

    @response['status'].should == 401
  end

  it 'should allow sending API token in HTTP header' do
    get "/api/v1/users/me", nil, {"HTTP_AUTHORIZATION" => "Token token=\"#{@user.token.access_token}\""}
    @response = JSON.parse(response.body)

    @response.has_key?("user").should be_true
  end

end
