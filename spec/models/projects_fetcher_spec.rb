require 'spec_helper'

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

  it 'should remove identities that are no longer participants in a project' do
    identity = FactoryGirl.create :identity, source_id: 1006
    identity2 = FactoryGirl.create :identity, source_id: 1007

    FakeWeb.register_uri(:get, 'https://www.pivotaltracker.com/services/v4/projects',
      :body => File.read(File.join(Rails.root, 'spec', 'fixtures', 'pivotal_tracker', 'responses', 'projects2.xml')),
      :status => ['200', 'OK'])

    @fetcher.fetch_for_identity(identity)
    Identity.count.should == 2
    identity.projects.count.should == 1
    identity2.projects.count.should == 1
    Project.first.identities.count.should == 2

    FakeWeb.register_uri(:get, 'https://www.pivotaltracker.com/services/v4/projects',
      :body => File.read(File.join(Rails.root, 'spec', 'fixtures', 'pivotal_tracker', 'responses', 'projects.xml')),
      :status => ['200', 'OK'])

    @fetcher.fetch_for_identity(identity)
    Identity.count.should == 2
    identity.projects.count.should == 1
    identity2.projects.count.should == 0
    Project.first.identities.count.should == 1
  end
end
