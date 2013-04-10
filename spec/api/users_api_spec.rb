require 'spec_helper'
require 'api/api_helper'

describe 'User API' do

  before :each do
    @user = FactoryGirl.create :user
  end

  it 'should return user\'s api_key when providing correct credentials' do
    api_get "users/authenticate", {email: @user.email, password: 'secret'}
    response.code.should == "200"
    JSON.parse(response.body)['token'].should == @user.api_key.access_token
  end

  it 'should not return api_key when providing wrong credentaials' do
    api_get "users/authenticate", {email: @user.email, password: 'wrong password'}
    response.code.should == "401"
  end

  it 'should allow API access when providing valid token' do
    api_get "users/me", {token: @user.api_key.access_token}
    user_response = JSON.parse(response.body)

    user_response.has_key?("user").should be_true
    user_response['user']['email'].should == @user.email
  end

  it 'should deny API access when providing invalid token' do
    api_get "users/me", {token: 'invalid token'}
    response.code.should == "401"
  end

  it 'should allow sending API token in HTTP header' do
    get "/api/v1/users/me", nil, {"HTTP_AUTHORIZATION" => "Token token=\"#{@user.api_key.access_token}\""}

    response.code.should == "200"
    user_response = JSON.parse(response.body)
    user_response.has_key?("user").should be_true
  end

end
