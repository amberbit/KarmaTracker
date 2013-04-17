require 'spec_helper'

describe 'GitHubProjectsFetcher' do

  before :all do
    reset_fakeweb_urls
    @fetcher = ProjectsFetcher.new
  end

  before :each do
    @identity = FactoryGirl.create :git_hub_identity, source_id: 'octocat'
    @identity2 = FactoryGirl.create :git_hub_identity, source_id: 'mickey_mouse'
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
    @identity.projects.count.should == 2
    Project.first.identities.count.should == 1
  end

  it 'should remove identities that are no longer participants in a project' do
  FakeWeb.register_uri(:get, /https:\/\/api\.github\.com\/repos\/.*\/.*\/collaborators/,
    :body => File.read(File.join(Rails.root, 'spec', 'fixtures', 'git_hub', 'responses', 'collaborators2.json')),
    :status => ['200', 'OK'])

    @fetcher.fetch_for_identity(@identity)
    Identity.count.should == 2
    @identity.projects.count.should == 0
    @identity2.projects.count.should == 2
    Project.first.identities.count.should == 1

    reset_fakeweb_urls

    @fetcher.fetch_for_identity(@identity)
    Identity.count.should == 2
    @identity.projects.count.should == 2
    @identity2.projects.count.should == 0
    Project.first.identities.count.should == 1
  end
end
