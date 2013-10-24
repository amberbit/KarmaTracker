require 'spec_helper'
require 'fakeweb'

describe 'IntegrationsFactory' do

  before :all do
    @attrs = {email: 'correct_email', password: 'correct_password'}
  end

  it 'should return an integration when correct params were provided' do
    factory = IntegrationsFactory.new(PivotalTrackerIntegration.new, @attrs)
    integration = factory.create
    integration.type.should == "PivotalTrackerIntegration"
  end

  it 'should return nil when wrong service was provided' do
    factory = IntegrationsFactory.new(Integration.new, @attrs)
    factory.create.valid?.should be_false
  end
end
