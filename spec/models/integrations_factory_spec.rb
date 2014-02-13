require 'spec_helper'
require 'fakeweb'

describe 'IntegrationsFactory' do

  before :all do
    @attrs = {username: 'correct_username', password: 'correct_password'}
  end

  it 'should return an integration when correct params were provided' do
    factory = IntegrationsFactory.new(IntegrationsFactory.construct_integration('pivotal_tracker'), @attrs)
    integration = factory.create
    integration.type.should == "PivotalTrackerIntegration"
  end

  it 'should return nil when wrong service was provided' do
    factory = IntegrationsFactory.new(Integration.new, @attrs)
    factory.create.valid?.should be_false
  end

  it 'should return new Git Hub integration' do
    IntegrationsFactory.construct_integration('git_hub').should be_kind_of GitHubIntegration
    IntegrationsFactory.construct_integration('GitHub').should be_kind_of GitHubIntegration
  end

  it 'should return new Pivotal Tracker integration' do
    IntegrationsFactory.construct_integration('pivotal_tracker').should be_kind_of PivotalTrackerIntegration
    IntegrationsFactory.construct_integration('PivotalTracker').should be_kind_of PivotalTrackerIntegration
  end

  it 'should raise error for unkown integration' do
    expect {
      IntegrationsFactory.construct_integration('unkown')
    }.to raise_error 'Unkown integration type. Supported are: GitHub/PivotalTracker'
  end
end
