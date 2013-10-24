require 'spec_helper'
require 'api/api_helper'
require 'fakeweb'

describe 'Integrations API' do
  # GET /api/v1/integrations/:id
  it 'should return integration details' do
    FactoryGirl.create :integration
    Integration.count.should == 1

    json = api_get "integrations/#{Integration.last.id}", {token: Integration.last.user.api_key.token}

    response.status.should == 200
    json['pivotal_tracker']['id'].should == Integration.last.id
    json['pivotal_tracker']['service'].should == "Pivotal Tracker"
    json['pivotal_tracker']['api_key'].should == Integration.last.api_key
  end

  # GET /api/v1/integrations
  it 'should return array of integrations' do
    3.times { FactoryGirl.create(:integration) }
    json = api_get 'integrations', {token: Integration.last.user.api_key.token}

    response.status.should == 200
    json.count.should == 3
  end

  # GET /api/v1/integrations
  it 'should not return other users\' integrations' do
    user1 = FactoryGirl.create :user
    user2 = FactoryGirl.create :user
    2.times { FactoryGirl.create(:integration, user: user1) }
    3.times { FactoryGirl.create(:integration, user: user2) }

    json = api_get 'integrations', {token: user1.api_key.token}
    response.status.should == 200

    json.count.should == 2
    json.each do |integration|
      user1.integrations.reload.map(&:id).should include(integration[integration.keys.first]['id'].to_i)
      user2.integrations.reload.map(&:id).should_not include(integration[integration.keys.first]['id'].to_i)
    end

    json = api_get 'integrations', {token: user2.api_key.token}
    response.status.should == 200
    json.count.should == 3
    json.each do |integration|
      user1.integrations.map(&:id).should_not include(integration[integration.keys.first]['id'].to_i)
      user2.integrations.map(&:id).should include(integration[integration.keys.first]['id'].to_i)
    end
  end

  # GET /api/v1/integrations?service=pivotal_tracker
  it 'should filter integrations by service' do
    2.times { FactoryGirl.create(:integration) }
    3.times { FactoryGirl.create(:integration, type: "GitHubIntegration") }

    json = api_get "integrations", {token: Integration.last.user.api_key.token, service: 'PivotalTracker'}
    json.select{ |i| i.has_key?('pivotal_tracker') }.count.should == 2
    json.select{ |i| i.has_key?('git_hub') }.count.should == 0
  end

  # POST /api/v1/integrations/pivotal_tracker
  it "should be able to add PT integration for given user" do
    user = FactoryGirl.create :user
    json = api_post "integrations/pivotal_tracker", {token: ApiKey.last.token, integration:
          { email: 'correct_email@example.com', password: 'correct_password'}}

    response.status.should == 200
    json.has_key?('pivotal_tracker').should be_true

    Integration.count.should == 1
    integration = Integration.last
    integration.user.should == user
    user.integrations.should include(integration)
  end

  # POST /api/v1/integrations/pivotal_tracker
  it "should be able to add PT integration for given user with provided token" do
    user = FactoryGirl.create :user
    json = api_post "integrations/pivotal_tracker", {token: ApiKey.last.token, integration:
          { api_key: 'correct_token'}}
    response.status.should == 200
    json.has_key?('pivotal_tracker').should be_true

    Integration.count.should == 1
    integration = Integration.last
    integration.user.should == user
    user.integrations.should include(integration)
  end


  # POST /api/v1/integrations/pivotal_tracker
  it 'should add error messages to response when adding PT integration fails' do
    FactoryGirl.create :user
    json = api_post "integrations/pivotal_tracker", {token: ApiKey.last.token, integration: {email: 'wrong_email', password: 'wrong_password'}}

    response.status.should == 422
    Integration.count.should == 0
    json['pivotal_tracker'].has_key?('errors').should be_true
    json['pivotal_tracker']['errors']['api_key'].should_not be_blank
  end

  # POST /api/v1/integrations/git_hub
  it "should be able to add GH integration for given user" do
    user = FactoryGirl.create :user
    json = api_post "integrations/git_hub", {token: ApiKey.last.token, integration:
          { username: 'correct_username@example.com', password: 'correct_password'}}

    response.status.should == 200
    json.has_key?('git_hub').should be_true

    Integration.count.should == 1
    integration = Integration.last
    integration.user.should == user
    user.integrations.should include(integration)
  end

  # POST /api/v1/integrations/git_hub
  it "should be able to add GH integration for given user with provided token" do
    user = FactoryGirl.create :user
    json = api_post "integrations/git_hub", {token: ApiKey.last.token, integration:
          { api_key: 'correct_token'}}

    response.status.should == 200
    json.has_key?('git_hub').should be_true

    Integration.count.should == 1
    integration = Integration.last
    integration.user.should == user
    integration.source_id.should == 'correct_username'
    user.integrations.should include(integration)
  end

  # POST /api/v1/integrations/git_hub
  it 'should add error messages to response when adding GH integration fails' do
    FactoryGirl.create :user
    json = api_post "integrations/git_hub", {token: ApiKey.last.token, integration: {username: 'wrong_username', password: 'wrong_password'}}

    response.status.should == 422
    Integration.count.should == 0
    json['git_hub'].has_key?('errors').should be_true
    json['git_hub']['errors']['password'].should == ['provided username/password combination is invalid']
  end

  # DELETE /api/v1/integrations/:id
  it "should be able to remove the integration and return it" do
    FactoryGirl.create :integration
    Integration.count.should == 1

    -> {
      @json = api_delete "integrations/#{Integration.last.id}", {token: Integration.last.user.api_key.token}
    }.should change(Integration, :count).by(-1)

    response.status.should == 200
    @json.has_key?('pivotal_tracker').should be_true
    Integration.count.should == 0
  end

  # DELETE /api/v1/integrations/:id
  it 'should return an error when trying to remove other usere\'s integration' do
    my_integration = FactoryGirl.create :integration, user: FactoryGirl.create(:user)
    other_integration = FactoryGirl.create :integration, user: FactoryGirl.create(:user)

    Integration.count.should == 2

    -> {
      @json = api_delete "integrations/#{other_integration.id}", {token: my_integration.user.api_key.token}
    }.should change(Integration, :count).by(0)

    response.status.should == 404
    Integration.count.should == 2
    @json['message'].should == "Resource not found"
  end

  # DELETE /api/v1/integrations/:id
  it 'should return an error when trying to remove not existing integration', rescue_errors: true do
    user = FactoryGirl.create :user

    json = api_delete "integrations/1", {token: user.api_key.token}

    response.status.should == 404
    json['message'].should == "Resource not found"
  end

end
