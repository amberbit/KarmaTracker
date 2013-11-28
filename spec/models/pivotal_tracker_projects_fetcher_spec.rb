require 'spec_helper'

describe 'PivotalTrackerProjectsFetcher
should' do

  before :all do
    reset_fakeweb_urls
    @fetcher = PivotalTrackerProjectsFetcher.new
  end

  before :each do
    @integration = FactoryGirl.create :integration, source_id: 1006
    @integration2 = FactoryGirl.create :integration, source_id: 1007
  end

  it 'should fetch projects for an integration' do
    @fetcher.fetch_projects(@integration)
    Project.count.should == 2
  end

  it 'not fetch a project twice' do
    @fetcher.fetch_projects(@integration)
    @fetcher.fetch_projects(@integration2)
    Project.count.should == 2
  end

  it 'should create associations between project and its members\' integrations' do

      FakeWeb.register_uri(:get, 'https://www.pivotaltracker.com/services/v5/projects/2/memberships',
      :body => File.read(File.join(Rails.root, 'spec', 'fixtures', 'pivotal_tracker', 'responses', 'membership3.json')),
      :status => ['200', 'OK'])

    @fetcher.fetch_projects(@integration)
    @integration.projects.count.should == 1
    Project.first.integrations.count.should == 1

    reset_fakeweb_urls
  end

  it 'remove integrations that are no longer participants in a project' do
    FakeWeb.register_uri(:get, 'https://www.pivotaltracker.com/services/v5/projects',
      :body => File.read(File.join(Rails.root, 'spec', 'fixtures', 'pivotal_tracker', 'responses', 'projects2.json')),
      :status => ['200', 'OK'])

    FakeWeb.register_uri(:get, 'https://www.pivotaltracker.com/services/v5/projects/1/memberships',
      :body => File.read(File.join(Rails.root, 'spec', 'fixtures', 'pivotal_tracker', 'responses', 'membership2.json')),
      :status => ['200', 'OK'])

    FakeWeb.register_uri(:get, 'https://www.pivotaltracker.com/services/v5/projects/2/memberships',
      :body => File.read(File.join(Rails.root, 'spec', 'fixtures', 'pivotal_tracker', 'responses', 'membership3.json')),
      :status => ['200', 'OK'])

    FakeWeb.register_uri(:get, 'https://www.pivotaltracker.com/services/v5/projects/3/memberships',
      :body => File.read(File.join(Rails.root, 'spec', 'fixtures', 'pivotal_tracker', 'responses', 'membership3.json')),
      :status => ['200', 'OK'])

    @fetcher.fetch_projects(@integration)
    Integration.count.should == 2
    @integration.projects.count.should == 1
    @integration2.projects.count.should == 1
    project = Project.first
    project.integrations.count.should == 2

    reset_fakeweb_urls
    reset_fakeweb_urls

    @fetcher.fetch_projects(@integration)
    Integration.count.should == 2
    @integration.projects.count.should == 1
    @integration2.projects.count.should == 0
    project.integrations.reload.count.should == 1

    reset_fakeweb_urls

  end

  it 'fetch tasks for project' do
    @fetcher.fetch_projects(@integration)
    @fetcher.fetch_tasks(@integration.projects.first, @integration)
    Task.count.should == 2
    Project.first.tasks.count.should == 2
  end

  it 'mark current tasks appropriately' do
    @fetcher.fetch_projects(@integration)
    @fetcher.fetch_tasks(@integration.projects.last, @integration)
    Task.count.should == 2
    Task.current.count.should == 1
  end

  it 'update current flag for tasks' do
    reset_fakeweb_urls

    @fetcher.fetch_projects(@integration)
    @fetcher.fetch_tasks(@integration.projects.last, @integration)
    Task.find_by_source_identifier('1').current_task.should be_true
    Task.find_by_source_identifier('4').current_task.should be_false

    FakeWeb.register_uri(:get, /https:\/\/www\.pivotaltracker\.com\/services\/v5\/projects\/[0-9]+\/iterations\?scope\=current/,
      :body => File.read(File.join(Rails.root, 'spec', 'fixtures', 'pivotal_tracker', 'responses', 'current_iteration2.json')),
      :status => ['200', 'OK'])

    @fetcher.fetch_projects(@integration)
    @fetcher.fetch_tasks(@integration.projects.last, @integration)
    Task.find_by_source_identifier('1').current_task.should be_false
    Task.find_by_source_identifier('4').current_task.should be_true

  end

  it 'not crash import when api key is invalid' do
    FakeWeb.register_uri(:get, "https://www.pivotaltracker.com/services/v5/projects", :status => ['401', 'Unauthorized'])
    expect {
      @fetcher.fetch_projects(@integration)
    }.not_to raise_error(OpenURI::HTTPError)
  end
end
