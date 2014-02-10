require 'spec_helper'
require 'fakeweb'

describe 'IntegrationsFactory' do

  before :all do
    @attrs = {username: 'correct_username', password: 'correct_password'}
  end

  it 'should return an integration when correct params were provided' do
    options = @attrs.merge({ type: 'pivotal_tracker' })
    factory = IntegrationsFactory.new(IntegrationsFactory.construct_integration(options), @attrs)
    integration = factory.create
    integration.type.should == "PivotalTrackerIntegration"
  end

  it 'should return nil when wrong service was provided' do
    factory = IntegrationsFactory.new(Integration.new, @attrs)
    factory.create.valid?.should be_false
  end
end
