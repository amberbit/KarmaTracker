require 'spec_helper'

describe 'ProjectsFetcher
should' do

  before :all do
    reset_fakeweb_urls
    @fetcher = ProjectsFetcher.new
  end

  before :each do
    @identity = create :identity, source_id: 1006
    @identity2 = create :git_hub_identity
  end
  
  it 'call fetch_for_user twice' do
    create :user
    @fetcher.should_receive(:fetch_for_user).exactly(2).times
    @fetcher.fetch_all
  end
  
  it 'call fetch_projects for both identities' do 
    PivotalTrackerProjectsFetcher.any_instance.should_receive(:fetch_projects).with(User.last.identities[0])
    GitHubProjectsFetcher.any_instance.should_receive(:fetch_projects).with(User.last.identities[1])
    @fetcher.fetch_for_user User.first
  end
  
  it 'call fetch_for_project' do
    PivotalTrackerProjectsFetcher.any_instance.should_receive(:fetch_tasks).with(@identity.projects.first, @identity)
    @fetcher.fetch_for_project(@identity.projects.first, @identity)
  end
  
  it 'call fetch_for_project for GitHubIdentity' do
    GitHubProjectsFetcher.any_instance.should_receive(:fetch_tasks_for_project).with(@identity2.projects.first, @identity2)
    @fetcher.fetch_for_project(@identity2.projects.first, @identity2)
  end
end