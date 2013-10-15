require 'spec_helper'

describe 'PivotalTrackerProjectsFetcher
should' do

  before :all do
    reset_fakeweb_urls
    @fetcher = PivotalTrackerProjectsFetcher.new
  end

  before :each do
    @identity = FactoryGirl.create :identity, source_id: 1006
    @identity2 = FactoryGirl.create :identity, source_id: 1007
  end

  it 'should fetch projects for an identity' do
    @fetcher.fetch_projects(@identity)
    Project.count.should == 2
  end

  it 'not fetch a project twice' do
    @fetcher.fetch_projects(@identity)
    @fetcher.fetch_projects(@identity2)
    Project.count.should == 2
  end

  it 'should create associations between project and its members\' identities' do
    @fetcher.fetch_projects(@identity)
    @identity.projects.count.should == 1
    Project.first.identities.count.should == 1
  end

  it 'remove identities that are no longer participants in a project' do
    FakeWeb.register_uri(:get, 'https://www.pivotaltracker.com/services/v4/projects',
      :body => File.read(File.join(Rails.root, 'spec', 'fixtures', 'pivotal_tracker', 'responses', 'projects2.xml')),
      :status => ['200', 'OK'])

    @fetcher.fetch_projects(@identity)
    Identity.count.should == 2
    @identity.projects.count.should == 1
    @identity2.projects.count.should == 1
    project = Project.first
    wait_until(10) { project.identities.count == 2 }

    reset_fakeweb_urls

    @fetcher.fetch_projects(@identity)
    Identity.count.should == 2
    @identity.projects.count.should == 1
    @identity2.projects.count.should == 0
    project.identities.reload.count.should == 1
  end

  it 'fetch tasks for project' do
    @fetcher.fetch_projects(@identity)
    @fetcher.fetch_tasks(@identity.projects.first, @identity)
    Task.count.should == 2
    wait_until(10) { Project.first.tasks.count == 2 }
  end

  it 'mark current tasks appropriately' do
    @fetcher.fetch_projects(@identity)
    @fetcher.fetch_tasks(@identity.projects.last, @identity)
    Task.count.should == 2
    Task.current.count.should == 1
  end

  it 'update current flag for tasks' do
    @fetcher.fetch_projects(@identity)
    @fetcher.fetch_tasks(@identity.projects.last, @identity)
    Task.find_by_source_identifier('1').current_task.should be_true
    Task.find_by_source_identifier('4').current_task.should be_false

    FakeWeb.register_uri(:get, /https:\/\/www\.pivotaltracker\.com\/services\/v4\/projects\/[0-9]+\/iterations\/current/,
      :body => File.read(File.join(Rails.root, 'spec', 'fixtures', 'pivotal_tracker', 'responses', 'current_iteration2.xml')),
      :status => ['200', 'OK'])

    @fetcher.fetch_projects(@identity)
    @fetcher.fetch_tasks(@identity.projects.last, @identity)
    Task.find_by_source_identifier('1').current_task.should be_false
    Task.find_by_source_identifier('4').current_task.should be_true

  end

  it 'not crash import when api key is invalid' do
    FakeWeb.register_uri(:get, "https://www.pivotaltracker.com/services/v4/projects", :status => ['401', 'Unauthorized'])
    expect {
      @fetcher.fetch_projects(@identity)
    }.not_to raise_error(OpenURI::HTTPError)
  end
end
