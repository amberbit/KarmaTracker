require 'spec_helper'
require 'api/api_helper'

describe 'Admin API #Identities' do

  before :each do
    @admin = FactoryGirl.create :admin
  end

  # GET /api/v1/admin/identities
  it 'should return all identities if provided valid admin API token, grouped by provider PT/GH' do
    3.times do
      FactoryGirl.create(:identity)
    end
    2.times do
      FactoryGirl.create(:identity, type: 'GitHubIdentity')
    end

    json = api_get 'admin/identities', {token: @admin.api_key.token}

    response.status.should == 200
    json.has_key?('pivotal_tracker').should be_true
    json.has_key?('git_hub').should be_true
    json['pivotal_tracker'].count.should == 3
    json['git_hub'].count.should == 2
  end

  # GET /api/v1/admin/identities/:id
  it 'should return identity with extra information if get via admin API' do
    identity = FactoryGirl.create(:identity)

    json = api_get "admin/identities/#{identity.id}", {token: @admin.api_key.token}
    json['identity'].has_key?('user_id').should be_true
    json['identity'].has_key?('source_id').should be_true
  end

  # POST /api/v1/admin/identities/pivotal_tracker
  it 'should allow admins to create PT identities for user with their valid PT credentials' do
    user = FactoryGirl.create :user
    identity = {name: 'PT', email: 'correct_email', password: 'correct_password', user_id: user.id}

    -> {
      @json = api_post 'admin/identities/pivotal_tracker', {identity: identity, token: @admin.api_key.token}
    }.should change(Identity, :count).by(1)

    response.status.should == 200
    @json.has_key?('identity').should be_true
    Identity.count.should == 1
  end

  # POST /api/v1/admin/identities/pivotal_tracker
  it 'should require valid user when creating PT identity by admin' do
    identity = {name: 'PT', email: 'correct_email', password: 'correct_password', user_id: '0'}

    -> {
      @json = api_post 'admin/identities/pivotal_tracker', {identity: identity, token: @admin.api_key.token}
    }.should change(Identity, :count).by(0)

    response.status.should == 422
    @json['identity'].has_key?('errors').should be_true
    @json['identity']['errors']['user'].should include('can\'t be blank')
  end

  # PUT /api/v1/admin/identities/:id
  it 'should allow admins to edit only selected fields in identites' do
    FakeWeb.register_uri(:get, 'https://www.pivotaltracker.com/services/v4/me',
      :body => File.read(File.join(Rails.root, 'spec', 'fixtures', 'pivotal_tracker', 'responses', 'authorization_success.xml')),
      :status => ['200', 'OK'])

    user = FactoryGirl.create :user
    attrs = {name: 'PT', email: 'correct_email', password: 'correct_password', user_id: user.id}
    identity = IdentitiesFactory.new(PivotalTrackerIdentity.new, attrs).create_identity
    identity.save
    old_identity = identity.dup

    json = api_put "admin/identities/#{identity.id}", {identity: {name: 'new name', api_key: 'new key'}, token: @admin.api_key.token}

    identity.reload
    identity.name.should == 'new name'
    identity.api_key.should == old_identity.api_key
  end

  # DELETE /api/v1/admin/identities/:id
  it 'should allow admins to delete any identity' do
    identity = FactoryGirl.create :identity

    -> {
      json = api_delete "admin/identities/#{identity.id}", {token: @admin.api_key.token}
    }.should change(Identity, :count).by(-1)
    response.status.should == 200
  end

end
