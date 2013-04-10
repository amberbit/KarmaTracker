require 'spec_helper'
require 'fakeweb'

describe 'IdentitiesFactory' do

  before :all do
    FakeWeb.register_uri(:get, 'https://correct_email:correct_password@www.pivotaltracker.com/services/v4/me',
      :body => File.read(File.join(Rails.root, 'spec', 'fixtures', 'pivotal_tracker', 'responses', 'authorization_success.xml')),
      :status => ['200', 'OK'])

    @attrs = {service: 'PivotalTracker', name: 'Test', email: 'correct_email', password: 'correct_password'}
  end

  it 'should return an identity when correct params were provided' do
    factory = IdentitiesFactory.new(@attrs)
    identity = factory.create_identity
    identity.name.should == @attrs[:name]
  end

  it 'should accept service name in CamelCase' do
    factory = IdentitiesFactory.new(@attrs)
    identity = factory.create_identity
    identity.is_a?(PivotalTrackerIdentity).should be_true
  end

  it 'should accept service name in snake_case' do
    factory = IdentitiesFactory.new(@attrs.merge(service: 'pivotal_tracker'))
    identity = factory.create_identity
    identity.is_a?(PivotalTrackerIdentity).should be_true
  end

  it 'should return nil when wrong service was provided' do
    factory = IdentitiesFactory.new(@attrs.merge(service: 'Abc'))
    factory.create_identity.should be_nil
  end
end
