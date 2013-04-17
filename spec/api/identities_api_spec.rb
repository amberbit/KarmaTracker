require 'spec_helper'
require 'api/api_helper'
require 'fakeweb'

describe 'Identities API' do
  # GET /api/v1/identities/:id
  it 'should return identity details' do
    ProjectsFetcher.any_instance.should_receive(:fetch_for_identity).and_return(nil)
    FactoryGirl.create :identity
    Identity.count.should == 1

    json = api_get "identities/#{Identity.last.id}", {token: Identity.last.user.api_key.token}

    response.status.should == 200
    json['pivotal_tracker']['id'].should == Identity.last.id
    json['pivotal_tracker']['service'].should == "Pivotal Tracker"
    json['pivotal_tracker']['name'].should == Identity.last.name
    json['pivotal_tracker']['api_key'].should == Identity.last.api_key
  end

  # GET /api/v1/identities
  it 'should return array of identities' do
    3.times { FactoryGirl.create(:identity) }
    json = api_get 'identities', {token: Identity.last.user.api_key.token}

    response.status.should == 200
    json.count.should == 3
  end

  # GET /api/v1/identities
  it 'should not return other users\' identities' do
    user1 = FactoryGirl.create :user
    user2 = FactoryGirl.create :user
    2.times { FactoryGirl.create(:identity, user: user1) }
    3.times { FactoryGirl.create(:identity, user: user2) }

    json = api_get 'identities', {token: user1.api_key.token}
    response.status.should == 200

    json.count.should == 2
    json.each do |identity|
      user1.identities.map(&:id).should include(identity[identity.keys.first]['id'].to_i)
      user2.identities.map(&:id).should_not include(identity[identity.keys.first]['id'].to_i)
    end

    json = api_get 'identities', {token: user2.api_key.token}
    response.status.should == 200
    json.count.should == 3
    json.each do |identity|
      user1.identities.map(&:id).should_not include(identity[identity.keys.first]['id'].to_i)
      user2.identities.map(&:id).should include(identity[identity.keys.first]['id'].to_i)
    end
  end

  # GET /api/v1/identities?service=pivotal_tracker
  it 'should filter identities by service' do
    2.times { FactoryGirl.create(:identity) }
    3.times { FactoryGirl.create(:identity, type: "GitHubIdentity") }

    json = api_get "identities", {token: Identity.last.user.api_key.token, service: 'PivotalTracker'}
    json.select{ |i| i.has_key?('pivotal_tracker') }.count.should == 2
    json.select{ |i| i.has_key?('git_hub') }.count.should == 0
  end

  # POST /api/v1/identities/pivotal_tracker
  it "should be able to add PT identity for given user" do
    user = FactoryGirl.create :user
    json = api_post "identities/pivotal_tracker", {token: ApiKey.last.token, identity:
          { name: 'Just an identity', email: 'correct_email', password: 'correct_password'}}

    response.status.should == 200
    json.has_key?('pivotal_tracker').should be_true

    Identity.count.should == 1
    identity = Identity.last
    identity.name.should == 'Just an identity'
    identity.user.should == user
    user.identities.should include(identity)
  end

  # POST /api/v1/identities/pivotal_tracker
  it 'should add error messages to response when adding PT identity fails' do
    FactoryGirl.create :user
    json = api_post "identities/pivotal_tracker", {token: ApiKey.last.token, identity: {name: 'Just an identity',
           email: 'wrong_email', password: 'wrong_password'}}

    response.status.should == 422
    Identity.count.should == 0
    json['pivotal_tracker'].has_key?('errors').should be_true
    json['pivotal_tracker']['errors']['password'].should == ['provided email/password combination is invalid']
  end

  # POST /api/v1/identities/git_hub
  it "should be able to add GH identity for given user" do
    user = FactoryGirl.create :user
    json = api_post "identities/git_hub", {token: ApiKey.last.token, identity:
          { name: 'Just an identity', username: 'correct_username', password: 'correct_password'}}

    response.status.should == 200
    json.has_key?('git_hub').should be_true

    Identity.count.should == 1
    identity = Identity.last
    identity.name.should == 'Just an identity'
    identity.user.should == user
    user.identities.should include(identity)
  end

  # POST /api/v1/identities/git_hub
  it 'should add error messages to response when adding GH identity fails' do
    FactoryGirl.create :user
    json = api_post "identities/git_hub", {token: ApiKey.last.token, identity: {name: 'Just an identity',
           username: 'wrong_email', password: 'wrong_password'}}

    response.status.should == 422
    Identity.count.should == 0
    json['git_hub'].has_key?('errors').should be_true
    json['git_hub']['errors']['password'].should == ['provided username/password combination is invalid']
  end

  # DELETE /api/v1/identities/:id
  it "should be able to remove the identity and return it" do
    FactoryGirl.create :identity
    Identity.count.should == 1

    -> {
      @json = api_delete "identities/#{Identity.last.id}", {token: Identity.last.user.api_key.token}
    }.should change(Identity, :count).by(-1)

    response.status.should == 200
    @json.has_key?('pivotal_tracker').should be_true
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
