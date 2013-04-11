require 'spec_helper'
require 'api/api_helper'

# Definitions: API Key = external service api key
#              Token = our API access token
#
# POST /sessions
# params: session[email]: a@b.com, session[password]: somepass}
#  - if logged in:
#    200 OK
#    { user: { id: 1, email: 'a@b.com', name: 'Hubert Lepicki', token: 'asdf2344' } }
#  - if credentials invalid
#    401 Unauthorized
#    { message: 'Invalid email or password' }

describe 'Session API' do

  before :each do
    @user = FactoryGirl.create :user
  end

  it 'should return user with api token when providing correct credentials' do
    json = api_post "sessions/", {session: {email: @user.email, password: 'secret'}}

    response.status.should == 200
    json.has_key?('user').should be_true
    json['user']['token'].should == @user.api_key.token
  end

  it 'should not return token when providing wrong credentaials' do
    json = api_post 'sessions/', {session: {email: @user.email, password: 'wrong password'}}

    response.status.should == 401
    json.has_key?('user').should be_false
    json['message'].should == 'Invalid email or password'
  end

end
