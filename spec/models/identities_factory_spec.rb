require 'spec_helper'
require 'fakeweb'

describe 'IdentitiesFactory' do

  before :all do
    FakeWeb.register_uri(:get, 'https://correct_email:correct_password@www.pivotaltracker.com/services/v4/me',
      :body => File.read(File.join(Rails.root, 'spec', 'fixtures', 'pivotal_tracker', 'responses', 'authorization_success.xml')),
      :status => ['200', 'OK'])

    @attrs = {name: 'Test', email: 'correct_email', password: 'correct_password'}
  end

  it 'should return an identity when correct params were provided' do
    factory = IdentitiesFactory.new(PivotalTrackerIdentity, @attrs)
    identity = factory.create_identity
    identity.name.should == @attrs[:name]
  end

  it 'should return nil when wrong service was provided' do
    factory = IdentitiesFactory.new(Identity, @attrs)
    factory.create_identity.valid?.should be_false
  end
end
