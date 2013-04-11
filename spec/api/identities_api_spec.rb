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
#   { identity: { id: 4, api_key: 'asdfasdfasdf4444' } }
# - if identity was not created:
#   422 Unprocessable entity
#   { identity: { api_key: 'asdfasdfasdf32323', errors: { api_key: ['Is invalid'] } } }
#   or
#   { identity: { email: 'a@b.com', password: "asdf', errors: { password: ['does not match email'] } } }
# - if unauthorized
#   401 Unauthorized
#   { message: "Invalid API Key' }

# Deleting identities
# DELETE /identities/:id
# - if deletion completed (my identity)
#   200 OK
#   { identity: { id: 4, api_key: 'asdfasdfasdf4444' } }
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

    json = api_get "identities/#{Identity.last.id}", {token: Identity.last.user.api_key.token}

    response.status.should == 200
    json['identity']['id'].should == Identity.last.id
    json['identity']['service'].should == "Pivotal Tracker"
    json['identity']['name'].should == Identity.last.name
    json['identity']['api_key'].should == Identity.last.api_key
  end

  it 'should return array of identities' do
    3.times { FactoryGirl.create(:identity) }
    json = api_get 'identities', {token: Identity.last.user.api_key.token}

    response.status.should == 200
    json['pivotal_tracker'].count.should == 3
  end

  it 'should filter identities by service' do
    2.times { FactoryGirl.create(:identity) }
    3.times { FactoryGirl.create(:identity, type: "GitHubIdentity") }

    json = api_get "identities", {token: Identity.last.user.api_key.token, service: 'PivotalTracker'}
    json['pivotal_tracker'].count.should == 2
    json['github'].count.should == 0
  end

  it "should be able to add identity" do
    FactoryGirl.create :user
    json = api_post "identities/pivotal_tracker", {token: ApiKey.last.token, identity: {service: 'PivotalTracker',
           name: 'Just an identity', email: 'correct_email', password: 'correct_password'}}

    response.status.should == 200
    json.has_key?('identity').should be_true

    Identity.count.should == 1
    identity = Identity.last
    identity.name.should == 'Just an identity'
  end

  it 'should add error messages to response when adding identity fails' do
    FactoryGirl.create :user
    json = api_post "identities/pivotal_tracker", {token: ApiKey.last.token, identity: {name: 'Just an identity',
           email: 'wrong_email', password: 'wrong_password'}}

    Identity.count.should == 0
    json['identity'].has_key?('errors').should be_true
    response.status.should == 422
    response.body.should =~ /provided email\/password combination is invalid/
  end

  it "should be able to remove the identity and return it" do
    FactoryGirl.create :identity
    Identity.count.should == 1

    -> {
      @json = api_delete "identities/#{Identity.last.id}", {token: Identity.last.user.api_key.token}
    }.should change(Identity, :count).by(-1)

    response.status.should == 200
    @json.has_key?('identity').should be_true
    Identity.count.should == 0
  end

  it 'should return an error when trying to remove other usere\'s identity' do
    my_identity = FactoryGirl.create :identity, user: FactoryGirl.create(:user)
    other_identity = FactoryGirl.create :identity, user: FactoryGirl.create(:user)

    Identity.count.should == 2

    -> {
      @json = api_delete "identities/#{other_identity.id}", {token: my_identity.user.api_key.token}
    }.should change(Identity, :count).by(0)

    response.status.should == 404
    @json['message'].should == 'Resource not found'
    Identity.count.should == 2
  end

  it 'should return an error when trying to remove not existing identity', rescue_errors: true do
    user = FactoryGirl.create :user

    expect {
      @json = api_delete "identities/1", {token: user.api_key.token}
    }.to raise_error
  end

end
