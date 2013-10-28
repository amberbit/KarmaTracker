require 'spec_helper'

describe 'GitHubProjectsFetcher' do

  before :all do
    reset_fakeweb_urls
    @fetcher = GitHubProjectsFetcher.new
  end

  before :each do
    @integration = FactoryGirl.create :git_hub_integration, source_id: 'octocat'
    @integration2 = FactoryGirl.create :git_hub_integration, source_id: 'mickey_mouse'
  end

  it 'should fetch projects for an integration' do
    @fetcher.fetch_projects(@integration)
    Project.count.should == 2
  end

  it 'should not fetch a project twice' do
    @fetcher.fetch_projects(@integration)
    @fetcher.fetch_projects(@integration2)
    Project.count.should == 2
  end

  it 'should create associations between project and its members\' integrations' do
    @fetcher.fetch_projects(@integration)
    @integration.projects.count.should == 2
    Project.first.integrations.count.should == 1
  end

  it 'should remove integrations that are no longer participants in a project' do
  FakeWeb.register_uri(:get, /https:\/\/api\.github\.com\/repos\/.*\/.*\/collaborators/,
    :body => File.read(File.join(Rails.root, 'spec', 'fixtures', 'git_hub', 'responses', 'collaborators2.json')),
    :status => ['200', 'OK'])

    @fetcher.fetch_projects(@integration)
    Integration.count.should == 2
    @integration.projects.count.should == 0
    @integration2.projects.count.should == 2
    Project.first.integrations.count.should == 1

    reset_fakeweb_urls

    @fetcher.fetch_projects(@integration)
    Integration.count.should == 2
    @integration.projects.count.should == 2
    @integration2.projects.count.should == 0
    Project.first.integrations.count.should == 1
  end

  it 'should fetch tasks for project' do
    @fetcher.fetch_projects(@integration)
    Task.count.should == 0
    @fetcher.fetch_tasks_for_project(@integration.projects.last, @integration)
    Task.count.should == 1
    Project.last.tasks.count.should == 1
  end

  it 'should mark current tasks appropriately' do
    @fetcher.fetch_projects(@integration)
    @fetcher.fetch_tasks_for_project(@integration.projects.last, @integration)
    Task.count.should == 1
    Task.current.count.should == 1
  end

  it 'should update current flag for tasks' do
    @fetcher.fetch_projects(@integration)
    @fetcher.fetch_tasks_for_project(@integration.projects.last, @integration)
    Task.last.current_task.should be_true

    FakeWeb.register_uri(:get, /https:\/\/api\.github\.com\/repos\/.*\/.*\/issues\?state\=closed/,
      :body => File.read(File.join(Rails.root, 'spec', 'fixtures', 'git_hub', 'responses', 'issues2.json')),
      :status => ['200', 'OK'])

    @fetcher.fetch_projects(@integration)
    @fetcher.fetch_tasks_for_project(@integration.projects.last, @integration)
    Task.last.current_task.should be_false

  end

  xit 'not import when api key is invalid' do
    #stubbing doesn't work, always returns 200 OK
    FakeWeb.clean_registry
    FakeWeb.register_uri(:get, /https:\/\/api\.github\.com\/user\/subscriptions/,
      :body => {"message"=>"Bad credentials"}, status: ['401', 'Unauthorized'])
    @fetcher.fetch_projects(@integration)
    Task.count.should == 2
    Project.last.tasks.count.should == 1
  end
end
