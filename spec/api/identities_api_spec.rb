require 'spec_helper'
require 'api/api_helper'
require 'fakeweb'

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
    response.code.should == '200'

    identity = JSON.parse(response.body)['identity']
    identity['id'].should == Identity.last.id
    identity['service'].should == "Pivotal Tracker"
    identity['name'].should == Identity.last.name
    identity['api_key'].should == Identity.last.api_key
  end

  it 'should return array of identities' do
    3.times { FactoryGirl.create(:identity) }

    api_get "identities", {token: Identity.last.user.api_key.access_token}
    response.code.should == '200'

    JSON.parse(response.body).count.should == 3
  end

  it 'should filter identities by service' do
    2.times { FactoryGirl.create(:identity) }
    3.times { FactoryGirl.create(:identity, type: nil) }

    api_get "identities", {token: Identity.last.user.api_key.access_token, service: 'PivotalTracker'}
    response.code.should == '200'

    JSON.parse(response.body).count.should == 2
  end

  it "should be able to add identity" do
    FactoryGirl.create :user
    api_post "identities", {token: ApiKey.last.access_token, service: 'PivotalTracker',
                            name: 'Just an identity', email: 'correct_email', password: 'correct_password'}

    response.code.should == '200'

    Identity.count.should == 1
    identity = Identity.last
    identity.name.should == 'Just an identity'
  end

  it 'should not allow adding incorrect identity' do
    FactoryGirl.create :user
    api_post "identities", {token: ApiKey.last.access_token, service: 'WrongService',
                            name: 'Just an identity', email: 'correct_email', password: 'correct_password'}

    response.code.should == '500'

    Identity.count.should == 0
  end

  it "should be able to remove the identity" do
    FactoryGirl.create :identity
    Identity.count.should == 1

    -> {
      api_delete "identities/#{Identity.last.id}", {token: Identity.last.user.api_key.access_token}
    }.should change(Identity, :count).by(-1)

    response.code.should == '200'

    Identity.count.should == 0
  end

  it 'should return an error when trying to remove other usere\'s identity' do
    FactoryGirl.create :identity
    Identity.count.should == 1

    -> {
      api_delete "identities/#{Identity.last.id}", {token: 'wrong_token'}
    }.should change(Identity, :count).by(0)

    response.code.should == '401'

    Identity.count.should == 1
  end
end
