require 'spec_helper'
require 'fakeweb'

describe 'IdentitiesFactory' do

  before :all do
    @attrs = {email: 'correct_email', password: 'correct_password'}
  end

  it 'should return an identity when correct params were provided' do
    factory = IdentitiesFactory.new(PivotalTrackerIdentity.new, @attrs)
    identity = factory.create
    identity.type.should == "PivotalTrackerIdentity"
  end

  it 'should return nil when wrong service was provided' do
    factory = IdentitiesFactory.new(Identity.new, @attrs)
    factory.create.valid?.should be_false
  end
end
