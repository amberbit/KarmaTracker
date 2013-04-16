require 'spec_helper'
require "torquebox"
require "torquebox-no-op"

describe 'ProjectsFetcher' do

  before :all do
    @fetcher = ProjectsFetcher.new
  end

  before :each do
    @identity = FactoryGirl.create :identity, source_id: 1006
    @identity2 = FactoryGirl.create :identity, source_id: 1007
  end

  it 'should fetch projects for an identity' do
    @fetcher.fetch_for_identity(@identity)
    Project.count.should == 2
  end

  it 'should not fetch a project twice' do
    @fetcher.fetch_for_identity(@identity)
    @fetcher.fetch_for_identity(@identity2)
    Project.count.should == 2
  end

  it 'should create associations between project and its members\' identities' do
    @fetcher.fetch_for_identity(@identity)
    @identity.projects.count.should == 1
    Project.first.identities.count.should == 1
  end

  it 'should fetch tasks when fetching projects' do
    @fetcher.fetch_for_identity(@identity)
    Task.count.should == 2
    Project.last.tasks.count.should == 2
  end

  it 'should mark current tasks appropriately' do
    @fetcher.fetch_for_identity(@identity)
    Task.count.should == 2
    Task.current.count.should == 1
  end

  it 'should update current flag for tasks' do
    @fetcher.fetch_for_identity(@identity)
    Task.find_by_source_identifier('1').current_task.should be_true
    Task.find_by_source_identifier('4').current_task.should be_false

    FakeWeb.register_uri(:get, /https:\/\/www\.pivotaltracker\.com\/services\/v4\/projects\/[0-9]+\/iterations\/current/,
      :body => File.read(File.join(Rails.root, 'spec', 'fixtures', 'pivotal_tracker', 'responses', 'current_iteration2.xml')),
      :status => ['200', 'OK'])

    @fetcher.fetch_for_identity(@identity)
    Task.find_by_source_identifier('1').current_task.should be_false
    Task.find_by_source_identifier('4').current_task.should be_true

    reset_fakeweb_urls
  end

  it 'should remove identities that are no longer participants in a project' do
    FakeWeb.register_uri(:get, 'https://www.pivotaltracker.com/services/v4/projects',
      :body => File.read(File.join(Rails.root, 'spec', 'fixtures', 'pivotal_tracker', 'responses', 'projects2.xml')),
      :status => ['200', 'OK'])

    @fetcher.fetch_for_identity(@identity)
    Identity.count.should == 2
    @identity.projects.count.should == 1
    @identity2.projects.count.should == 1
    Project.first.identities.count.should == 2

    reset_fakeweb_urls

    @fetcher.fetch_for_identity(@identity)
    Identity.count.should == 2
    @identity.projects.count.should == 1
    @identity2.projects.count.should == 0
    Project.first.identities.count.should == 1
  end
end
