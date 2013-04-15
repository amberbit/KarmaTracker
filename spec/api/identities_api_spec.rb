require 'spec_helper'
require 'api/api_helper'
require 'torquebox'
require 'torquebox-no-op'
require 'fakeweb'

describe 'Identities API' do
  before :all do
    FakeWeb.register_uri(:get, 'https://correct_email:correct_password@www.pivotaltracker.com/services/v4/me',
      :body => File.read(File.join(Rails.root, 'spec', 'fixtures', 'pivotal_tracker', 'responses', 'authorization_success.xml')),
      :status => ['200', 'OK'])

    FakeWeb.register_uri(:get, 'https://www.pivotaltracker.com/services/v4/projects',
      :body => File.read(File.join(Rails.root, 'spec', 'fixtures', 'pivotal_tracker', 'responses', 'projects.xml')),
      :status => ['200', 'OK'])
  end

  # GET /api/v1/identities/:id
  it 'should return identity details' do
    ProjectsFetcher.any_instance.should_receive(:fetch_for_identity).and_return(nil)
    FactoryGirl.create :identity
    Identity.count.should == 1

    json = api_get "identities/#{Identity.last.id}", {token: Identity.last.user.api_key.token}

    response.status.should == 200
    json['identity']['id'].should == Identity.last.id
    json['identity']['service'].should == "Pivotal Tracker"
    json['identity']['name'].should == Identity.last.name
    json['identity']['api_key'].should == Identity.last.api_key
  end

  # GET /api/v1/identities
  it 'should return array of identities' do
    3.times { FactoryGirl.create(:identity) }
    json = api_get 'identities', {token: Identity.last.user.api_key.token}

    response.status.should == 200
    json['pivotal_tracker'].count.should == 3
  end

  # GET /api/v1/identities
  it 'should not return other users\' identities' do
    user1 = FactoryGirl.create :user
    user2 = FactoryGirl.create :user
    2.times { FactoryGirl.create(:identity, user: user1) }
    3.times { FactoryGirl.create(:identity, user: user2) }

    json = api_get 'identities', {token: user1.api_key.token}
    response.status.should == 200

    json['pivotal_tracker'].count.should == 2
    json['pivotal_tracker'].each do |identity|
      user1.identities.map(&:id).should include(identity['id'].to_i)
      user2.identities.map(&:id).should_not include(identity['id'].to_i)
    end

    json = api_get 'identities', {token: user2.api_key.token}
    response.status.should == 200
    json['pivotal_tracker'].count.should == 3
    json['pivotal_tracker'].each do |identity|
      user1.identities.map(&:id).should_not include(identity['id'].to_i)
      user2.identities.map(&:id).should include(identity['id'].to_i)
    end
  end

  # GET /api/v1/identities?service=pivotal_tracker
  it 'should filter identities by service' do
    2.times { FactoryGirl.create(:identity) }
    3.times { FactoryGirl.create(:identity, type: "GitHubIdentity") }

    json = api_get "identities", {token: Identity.last.user.api_key.token, service: 'PivotalTracker'}
    json['pivotal_tracker'].count.should == 2
    json['git_hub'].count.should == 0
  end

  # POST /api/v1/identities/pivotal_tracker
  it "should be able to add identity for given user" do
    user = FactoryGirl.create :user
    json = api_post "identities/pivotal_tracker", {token: ApiKey.last.token, identity:
          { name: 'Just an identity', email: 'correct_email', password: 'correct_password'}}

    response.status.should == 200
    json.has_key?('identity').should be_true

    Identity.count.should == 1
    identity = Identity.last
    identity.name.should == 'Just an identity'
    identity.user.should == user
    user.identities.should include(identity)
  end

  # POST /api/v1/identities/pivotal_tracker
  it 'should add error messages to response when adding identity fails' do
    FactoryGirl.create :user
    json = api_post "identities/pivotal_tracker", {token: ApiKey.last.token, identity: {name: 'Just an identity',
           email: 'wrong_email', password: 'wrong_password'}}

    response.status.should == 422
    Identity.count.should == 0
    json['identity'].has_key?('errors').should be_true
    json['identity']['errors']['password'].should == ['provided email/password combination is invalid']
  end

  # DELETE /api/v1/identities/:id
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

  # DELETE /api/v1/identities/:id
  it 'should return an error when trying to remove other usere\'s identity' do
    my_identity = FactoryGirl.create :identity, user: FactoryGirl.create(:user)
    other_identity = FactoryGirl.create :identity, user: FactoryGirl.create(:user)

    Identity.count.should == 2

    -> {
      @json = api_delete "identities/#{other_identity.id}", {token: my_identity.user.api_key.token}
    }.should change(Identity, :count).by(0)

    response.status.should == 404
    Identity.count.should == 2
    @json['message'].should == "Resource not found"
  end

  # DELETE /api/v1/identities/:id
  it 'should return an error when trying to remove not existing identity', rescue_errors: true do
    user = FactoryGirl.create :user

    json = api_delete "identities/1", {token: user.api_key.token}

    response.status.should == 404
    json['message'].should == "Resource not found"
  end

end
