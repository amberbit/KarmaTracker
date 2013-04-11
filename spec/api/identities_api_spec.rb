require 'spec_helper'
require 'api/api_helper'
require 'fakeweb'

# GET /identities
# 200 OK
# { pivotal_tracker: [
#   { id: 1, api_key: 'asdf1234' }
#   { id: 3, api_key: 'asdf123a' }
# ],
#   github: [
#   { id: 2, api_key: 'asdf323423' }
# ]}
#
# or
# 401 Unauthorized
# { message: "Invalid API Key' }

# Adding identities
# POST /identities/pivotal_tracker
# params: identity[api_key] = 'asdfasdf343434'
# OR:
# params: identity[email] = 'a@b.com', identity[password] = 'asdfasdf'
# - if identity was created:
#   200 OK
#   { id: 4, api_key: 'asdfasdfasdf4444' }
# - if identity was not created:
#   422 Unprocessable entity
#   { api_key: 'asdfasdfasdf32323', errors: { api_key: ['Is invalid'] } }
#   or
#   { email: 'a@b.com', password: "asdf', errors: { password: ['does not match email'] } }
# - if unauthorized
#   401 Unauthorized
#   { message: "Invalid API Key' }

# Deleting identities
# DELETE /identities/:id
# - if deletion completed (my identity)
#   200 OK
#   { id: 4, api_key: 'asdfasdfasdf4444' }
# - if deletion failed (not my identity or identity does not exist)
#   404 Not Found
#   { message: 'Resource not found' }
# - if unauthorized
#   401 Unauthorized
#   { message: "Invalid API Key' }

describe 'Identities API' do
  before :all do
    FakeWeb.register_uri(:get, 'https://correct_email:correct_password@www.pivotaltracker.com/services/v4/me',
      :body => File.read(File.join(Rails.root, 'spec', 'fixtures', 'pivotal_tracker', 'responses', 'authorization_success.xml')),
      :status => ['200', 'OK'])
  end

  it 'should return identity details' do
    FactoryGirl.create :identity
    Identity.count.should == 1

    api_get "identities/#{Identity.last.id}", {token: Identity.last.user.api_key.access_token}

    @response['identity']['id'].should == Identity.last.id
    @response['identity']['service'].should == "Pivotal Tracker"
    @response['identity']['name'].should == Identity.last.name
    @response['identity']['api_key'].should == Identity.last.api_key
  end

  it 'should return array of identities' do
    3.times { FactoryGirl.create(:identity) }

    api_get "identities", {token: Identity.last.user.api_key.access_token}

    @response.count.should == 3
  end

  it 'should filter identities by service' do
    2.times { FactoryGirl.create(:identity) }
    3.times { FactoryGirl.create(:identity, type: nil) }

    api_get "identities", {token: Identity.last.user.api_key.access_token, service: 'PivotalTracker'}

    @response.count.should == 2
  end

  it "should be able to add identity" do
    FactoryGirl.create :user
    api_post "identities", {token: ApiKey.last.access_token, service: 'PivotalTracker',
                            name: 'Just an identity', email: 'correct_email', password: 'correct_password'}

    @response['status'].should == 200

    Identity.count.should == 1
    identity = Identity.last
    identity.name.should == 'Just an identity'
  end

  it 'should not allow adding incorrect identity' do
    FactoryGirl.create :user
    api_post "identities", {token: ApiKey.last.access_token, service: 'WrongService',
                            name: 'Just an identity', email: 'correct_email', password: 'correct_password'}

    @response['status'].should == 500

    Identity.count.should == 0
  end

  it "should be able to remove the identity" do
    FactoryGirl.create :identity
    Identity.count.should == 1

    -> {
      api_delete "identities/#{Identity.last.id}", {token: Identity.last.user.api_key.access_token}
    }.should change(Identity, :count).by(-1)

    @response['status'].should == 200

    Identity.count.should == 0
  end

  it 'should return an error when trying to remove other usere\'s identity' do
    FactoryGirl.create :identity
    Identity.count.should == 1

    -> {
      api_delete "identities/#{Identity.last.id}", {token: 'wrong_token'}
    }.should change(Identity, :count).by(0)

    @response['status'].should == 401

    Identity.count.should == 1
  end
end
