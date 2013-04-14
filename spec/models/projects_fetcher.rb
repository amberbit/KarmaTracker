require 'spec_helper'
require "torquebox"
require "torquebox-no-op"

describe 'ProjectsFetcher' do

  before :all do
    @fetcher = ProjectsFetcher.new
  end

  it 'should fetch projects for an identity' do
    identity = FactoryGirl.create :identity
    @fetcher.fetch_for_identity(identity)
    Project.count.should == 2
  end

  it 'should not fetch a project twice' do
    identity = FactoryGirl.create :identity
    identity2 = FactoryGirl.create :identity
    @fetcher.fetch_for_identity(identity)
    @fetcher.fetch_for_identity(identity2)
    Project.count.should == 2
  end

  it 'should create associations between project and its members\' identities' do
    identity = FactoryGirl.create :identity, source_id: 1006

    @fetcher.fetch_for_identity(identity)
    identity.projects.count.should == 1
    Project.first.identities.count.should == 1
  end

  it 'should fetch tasks when fetching projects' do
    identity = FactoryGirl.create :identity
    @fetcher.fetch_for_identity(identity)

    Task.count.should == 2
    Project.last.tasks.count.should == 2
  end
end
