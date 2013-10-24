require 'spec_helper'

describe 'ProjectsFetcher
should' do

  before :all do
    reset_fakeweb_urls
    @fetcher = ProjectsFetcher.new
  end

  before :each do
    @integration = create :integration, source_id: 1006
    @integration2 = create :git_hub_integration
  end
  
  it 'call fetch_for_user twice' do
    create :user
    @fetcher.should_receive(:fetch_for_user).exactly(2).times
    @fetcher.fetch_all
  end
  
  it 'call fetch_projects for both integrations' do 
    PivotalTrackerProjectsFetcher.any_instance.should_receive(:fetch_projects).with(User.last.integrations[0])
    GitHubProjectsFetcher.any_instance.should_receive(:fetch_projects).with(User.last.integrations[1])
    @fetcher.fetch_for_user User.first
  end
  
  it 'call fetch_for_project' do
    PivotalTrackerProjectsFetcher.any_instance.should_receive(:fetch_tasks).with(@integration.projects.first, @integration)
    @fetcher.fetch_for_project(@integration.projects.first, @integration)
  end
  
  it 'call fetch_for_project for GitHubIntegration' do
    GitHubProjectsFetcher.any_instance.should_receive(:fetch_tasks_for_project).with(@integration2.projects.first, @integration2)
    @fetcher.fetch_for_project(@integration2.projects.first, @integration2)
  end
  
  it 'update only project\'s (not tasks)' do
    Project.delete_all
    expect {
      @fetcher.fetch_for_user User.first
      Project.count.should == 4
    }.not_to change{Task.count}
  end
end
